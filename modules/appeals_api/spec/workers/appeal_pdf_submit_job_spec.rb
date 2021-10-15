# frozen_string_literal: true

require 'rails_helper'
require AppealsApi::Engine.root.join('spec', 'spec_helper.rb')
require AppealsApi::Engine.root.join('spec', 'support', 'shared_examples_for_monitored_worker.rb')

require 'appeals_api/hlr_pdf_submit_handler'
require 'appeals_api/nod_pdf_submit_handler'

RSpec.describe AppealsApi::AppealPdfSubmitJob, type: :job do
  include FixtureHelpers

  subject { described_class }

  before { Sidekiq::Worker.clear_all }

  let(:auth_headers) { fixture_to_s 'valid_200996_headers.json' }
  let(:higher_level_review) { create_higher_level_review }
  let(:notice_of_disagreement) { create(:notice_of_disagreement) }
  let(:client_stub) { instance_double('CentralMail::Service') }
  let(:faraday_response) { instance_double('Faraday::Response') }
  let(:valid_doc) { fixture_to_s 'valid_200996.json' }

  it_behaves_like 'a monitored worker'

  describe 'uploads a valid payload' do
    it 'HLR' do
      Timecop.freeze(DateTime.new(2020, 1, 1).utc) do
        file_digest_stub = instance_double('Digest::SHA256')
        allow(Digest::SHA256).to receive(:file) { file_digest_stub }
        allow(file_digest_stub).to receive(:hexdigest).and_return('file_digest_12345')

        allow(CentralMail::Service).to receive(:new) { client_stub }
        allow(faraday_response).to receive(:status).and_return(200)
        allow(faraday_response).to receive(:body).and_return('')
        allow(faraday_response).to receive(:success?).and_return(true)
        capture_body = nil
        expect(client_stub).to receive(:upload) { |arg|
          capture_body = arg
          faraday_response
        }
        described_class.new.perform(higher_level_review.id, handler: AppealsApi::HlrPdfSubmitHandler,
                                                            appeal_klass: AppealsApi::HigherLevelReview)
        metadata = JSON.parse(capture_body['metadata'])

        expect(capture_body).to be_a(Hash)
        expect(capture_body).to have_key('metadata')
        expect(metadata).to eq({
                                 'veteranFirstName' => 'Jane',
                                 'veteranLastName' => 'Doe',
                                 'fileNumber' => '987654321',
                                 'zipCode' => '66002',
                                 'source' => 'Appeals-HLR-va.gov',
                                 'uuid' => higher_level_review.id,
                                 'hashV' => 'file_digest_12345',
                                 'numberAttachments' => 0,
                                 'receiveDt' => '2019-12-31 18:00:00',
                                 'numberPages' => 2,
                                 'docType' => '20-0996'
                               })
        expect(capture_body).to have_key('document')
        expect(capture_body['document'].original_filename).to eq('200996-document.pdf')
        expect(capture_body['document'].content_type).to eq('application/pdf')

        updated = AppealsApi::HigherLevelReview.find(higher_level_review.id)
        expect(updated.status).to eq('submitted')
      end
    end

    it 'NOD' do
      Timecop.freeze(DateTime.new(2020, 1, 1).utc) do
        allow(CentralMail::Service).to receive(:new) { client_stub }
        file_digest_stub = instance_double('Digest::SHA256')
        allow(Digest::SHA256).to receive(:file) { file_digest_stub }
        allow(file_digest_stub).to receive(:hexdigest).and_return('file_digest_12345')

        allow(faraday_response).to receive(:status).and_return(200)
        allow(faraday_response).to receive(:body).and_return('')
        allow(faraday_response).to receive(:success?).and_return(true)
        capture_body = nil
        expect(client_stub).to receive(:upload) { |arg|
          capture_body = arg
          faraday_response
        }
        described_class.new.perform(notice_of_disagreement.id, handler: AppealsApi::NodPdfSubmitHandler,
                                                               appeal_klass: AppealsApi::NoticeOfDisagreement)
        expect(capture_body).to be_a(Hash)
        expect(capture_body).to have_key('metadata')
        expect(capture_body).to have_key('document')
        metadata = JSON.parse(capture_body['metadata'])
        expect(metadata).to eq({
                                 'veteranFirstName' => 'Jane',
                                 'veteranLastName' => 'Doe',
                                 'fileNumber' => '987654321',
                                 'zipCode' => '00000',
                                 'source' => 'Appeals-NOD-va.gov',
                                 'uuid' => notice_of_disagreement.id,
                                 'hashV' => 'file_digest_12345',
                                 'numberAttachments' => 0,
                                 'receiveDt' => '2019-12-31 18:00:00',
                                 'numberPages' => 4,
                                 'docType' => '10182',
                                 'lob' => 'BVA'
                               })
        expect(metadata['uuid']).to eq(notice_of_disagreement.id)
        expect(metadata['lob']).to eq(notice_of_disagreement.lob)

        expect(capture_body['document'].original_filename).to eq('10182-document.pdf')
        expect(capture_body['document'].content_type).to eq('application/pdf')

        updated = AppealsApi::NoticeOfDisagreement.find(notice_of_disagreement.id)
        expect(updated.status).to eq('submitted')
      end
    end
  end

  it 'sets error status for upstream server error' do
    allow(CentralMail::Service).to receive(:new) { client_stub }
    allow(faraday_response).to receive(:status).and_return(422)
    allow(faraday_response).to receive(:body).and_return('')
    allow(faraday_response).to receive(:success?).and_return(false)
    capture_body = nil
    expect(client_stub).to receive(:upload) { |arg|
      capture_body = arg
      faraday_response
    }

    expect do
      described_class.new.perform(higher_level_review.id, handler: AppealsApi::HlrPdfSubmitHandler,
                                                          appeal_klass: AppealsApi::HigherLevelReview)
    end.to raise_error(AppealsApi::UploadError)
    expect(capture_body).to be_a(Hash)
    expect(capture_body).to have_key('metadata')
    expect(capture_body).to have_key('document')
    metadata = JSON.parse(capture_body['metadata'])
    expect(metadata['uuid']).to eq(higher_level_review.id)
    updated = AppealsApi::HigherLevelReview.find(higher_level_review.id)
    expect(updated.status).to eq('error')
    expect(updated.code).to eq('DOC104')
  end

  context 'with a downstream error' do
    before do
      allow(CentralMail::Service).to receive(:new) { client_stub }
      allow(faraday_response).to receive(:status).and_return(500)
      allow(faraday_response).to receive(:body).and_return('')
      allow(faraday_response).to receive(:success?).and_return(false)
    end

    it 'puts the HLR into an error state' do
      expect(client_stub).to receive(:upload) { |_arg| faraday_response }
      messager_instance = instance_double(AppealsApi::Slack::Messager)
      allow(AppealsApi::Slack::Messager).to receive(:new).and_return(messager_instance)
      allow(messager_instance).to receive(:notify!).and_return(true)
      described_class.new.perform(higher_level_review.id, handler: AppealsApi::HlrPdfSubmitHandler,
                                                          appeal_klass: AppealsApi::HigherLevelReview)
      expect(higher_level_review.reload.status).to eq('error')
      expect(higher_level_review.code).to eq('DOC201')
    end

    it 'sends a retry notification' do
      expect(client_stub).to receive(:upload) { |_arg| faraday_response }
      messager_instance = instance_double(AppealsApi::Slack::Messager)
      allow(AppealsApi::Slack::Messager).to receive(:new).and_return(messager_instance)
      allow(messager_instance).to receive(:notify!).and_return(true)
      described_class.new.perform(higher_level_review.id, handler: AppealsApi::HlrPdfSubmitHandler,
                                                          appeal_klass: AppealsApi::HigherLevelReview)

      expect(messager_instance).to have_received(:notify!)
    end
  end

  context 'an error throws' do
    it 'updates the HLR status to reflect the error' do
      submit_job_worker = described_class.new
      allow(submit_job_worker).to receive(:upload_to_central_mail).and_raise(RuntimeError, 'runtime error!')

      expect do
        submit_job_worker.perform(higher_level_review.id, handler: AppealsApi::HlrPdfSubmitHandler,
                                                          appeal_klass: AppealsApi::HigherLevelReview)
      end.to raise_error(RuntimeError, 'runtime error!')

      higher_level_review.reload
      expect(higher_level_review.status).to eq('error')
      expect(higher_level_review.code).to eq('RuntimeError')
    end
  end

  private

  def create_higher_level_review
    higher_level_review = create(:higher_level_review)
    higher_level_review.auth_headers = JSON.parse(auth_headers)
    higher_level_review.save
    higher_level_review
  end
end
