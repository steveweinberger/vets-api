# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::CaregiversAssistanceClaimsController, type: :controller do
  let(:facility_label) { '740 - Harlingen VA Clinic' }
  let(:missing_param_error) do
    {
      'title' => 'Missing parameter',
      'code' => '108',
      'status' => '400'
    }
  end

  let(:invalid_param_error) do
    {
      'title' => "did not contain a required property of 'veteran'",
      'code' => '100',
      'status' => '422'
    }
  end

  def confirm_expected_response_errors(response, status, size, expected_errors)
    response_body = JSON.parse(response.body)
    expect(response).to have_http_status(status)
    expect(response_body['errors']).to be_present
    expect(response_body['errors'].size).to eq(size)
    response_body['errors'].each_with_index do |response_error, index|
      confirm_individual_response_error(response_error, expected_errors[index])
    end
  end

  def confirm_individual_response_error(response_error, expected_error)
    response_error.each do |key|
      expect(response_error[key]).to include(expected_error[key]) if expected_error[key]
    end
  end

  def confirm_service_does_not_process_claim
    expect_any_instance_of(Form1010cg::Service).not_to receive(:process_claim!)
  end

  def confirm_new_cg_claim(form_data, claim)
    expect(SavedClaim::CaregiversAssistanceClaim).to receive(:new).with(
      form: form_data
    ).and_return(
      claim
    )
  end

  def delete_file(file)
    File.delete(file) if File.exist?(file)
  end

  def confirm_uuid
    # When controller generates it for filename
    expect(SecureRandom).to receive(:uuid).and_return('file-name-uuid')
  end

  def confirm_auditor_receives_record_with_pdf_download
    expect(described_class::AUDITOR).to receive(:record).with(:pdf_download)
  end

  def confirm_pdfs_match(response_pdf, expected_pdf)
    # compare it with the pdf fixture
    expect(pdfs_fields_match?(response_pdf, expected_pdf)).to eq(true)
  end

  def confirm_tmp_file_deleted
    # ensure that the tmp file was deleted
    expect(File.exist?('tmp/pdfs/10-10CG_file-name-uuid.pdf')).to eq(false)
  end

  shared_examples '10-10CG request with missing param: caregivers_assistance_claim' do |controller_action|
    let(:claim) { build(:caregivers_assistance_claim) }
    let(:expected_errors) do
      detail = { 'detail' => 'The required parameter "caregivers_assistance_claim", is missing' }
      [missing_param_error.merge(detail)]
    end

    before do
      expect(Raven).not_to receive(:tags_context).with(claim_guid: claim.guid)
      if controller_action == '#create'
        expect(described_class::AUDITOR).to receive(:record).with(:submission_attempt)
        expect(described_class::AUDITOR).to receive(:record).with(
          :submission_failure_client_data,
          errors: ['param is missing or the value is empty: caregivers_assistance_claim']
        )
      end
      confirm_service_does_not_process_claim
    end

    it 'requires "caregivers_assistance_claim" param' do      
      post controller_action, params: {}
      confirm_expected_response_errors(response, :bad_request, 1, expected_errors)
    end
  end

  shared_examples '10-10CG request with missing param: form' do |controller_action|
    let(:claim) { build(:caregivers_assistance_claim) }
    let(:expected_errors) do
      detail = { 'detail' => 'The required parameter "form", is missing' }
      [missing_param_error.merge(detail)]
    end

    before do
      expect(Raven).not_to receive(:tags_context).with(claim_guid: claim.guid)
      if controller_action == '#create'
        expect(described_class::AUDITOR).to receive(:record).with(:submission_attempt)
        expect(described_class::AUDITOR).to receive(:record).with(
          :submission_failure_client_data,
          errors: ['param is missing or the value is empty: form']
        )
      end
      confirm_service_does_not_process_claim
    end

    it 'requires "caregivers_assistance_claim.form" param' do      
      post controller_action, params: { caregivers_assistance_claim: { form: nil } }
      confirm_expected_response_errors(response, :bad_request, 1, expected_errors)
    end
  end

  shared_examples '10-10CG request with invalid form data' do |controller_action|
    let(:form_data) { '{}' }
    let(:params) { { caregivers_assistance_claim: { form: form_data } } }
    let(:claim) { build(:caregivers_assistance_claim, form: form_data) }
    let(:expected_errors) do
      [
        invalid_param_error.merge({ 'detail' => "did not contain a required property of 'veteran' in schema" }),
        invalid_param_error.merge(
          {
            'title' => 'did not match one or more of the required schemas',
            'detail' => 'did not match one or more of the required schemas'
          }
        )
      ]
    end
    let(:the_expected_errors) do
      # Need to build a duplicate claim in order to not change the state of the
      # mocked claim that is passed into the src code for testing
      build(:caregivers_assistance_claim, form: form_data).tap(&:valid?).errors.messages
    end

    before do
      expect(Raven).not_to receive(:tags_context).with(claim_guid: claim.guid)

      expect(described_class::AUDITOR).to receive(:record).with(:submission_attempt)
      expect(described_class::AUDITOR).to receive(:record).with(
        :submission_failure_client_data,
        claim_guid: claim.guid,
        errors: the_expected_errors
      )
    end

    it 'builds a claim and raises its errors' do
      confirm_service_does_not_process_claim
      confirm_new_cg_claim(form_data, claim)
      expect(Form1010cg::Service).not_to receive(:new).with(claim)
      post controller_action, params: params
      confirm_expected_response_errors(response, '422', 2, expected_errors)
    end
  end

  shared_examples '10-10CG valid request with pdf' do
    let(:claim) { build(:caregivers_assistance_claim, form: form_data) }
    let(:form_data) { form_data = get_fixture('pdf_fill/10-10CG/simple').to_json }
    let(:params) { { caregivers_assistance_claim: { form: form_data } } }
    let(:response_pdf) { Rails.root.join 'tmp', 'pdfs', '10-10CG_from_response.pdf' }
    let(:expected_pdf) { Rails.root.join 'spec', 'fixtures', 'pdf_fill', '10-10CG', 'unsigned', 'simple.pdf' }

    after do
      delete_file(response_pdf)
    end

    it 'generates a filled out 10-10CG and sends file as response', run_at: '2017-07-25 00:00:00 -0400' do
      confirm_new_cg_claim(form_data, claim)
      confirm_uuid
      confirm_auditor_receives_record_with_pdf_download

      post :download_pdf, params: params
      expect(response).to have_http_status(:ok)

      # download response content (the pdf) to disk
      File.open(response_pdf, 'wb+') { |f| f.write(response.body) }
      confirm_pdfs_match(response_pdf, expected_pdf)
      confirm_tmp_file_deleted
    end
  end

  shared_examples 'valid service claim' do
    let(:claim) { build(:caregivers_assistance_claim) }
    let(:form_data) { claim.form }
    let(:params) { { caregivers_assistance_claim: { form: form_data } } }
    let(:service) { double }
    let(:submission) do
      double(
        carma_case_id: 'A_123',
        accepted_at: DateTime.now.iso8601,
        metadata: :metadata_submitted,
        attachments: :attachments_uploaded,
        attachments_job_id: '1234abcdef'
      )
    end

    it 'submits claim successfully using Form1010cg::Service' do
      confirm_new_cg_claim(form_data, claim)

      expect(Raven).to receive(:tags_context).once.with(claim_guid: claim.guid)
      allow(Raven).to receive(:tags_context).with(any_args).and_call_original

      expect(Form1010cg::Service).to receive(:new).with(claim).and_return(service)
      expect(service).to receive(:process_claim!).with(facility_label).and_return(submission)

      expect(described_class::AUDITOR).to receive(:record).with(:submission_attempt)
      expect(described_class::AUDITOR).to receive(:record).with(
        :submission_success,
        claim_guid: claim.guid,
        carma_case_id: submission.carma_case_id,
        metadata: submission.metadata,
        attachments: submission.attachments,
        attachments_job_id: submission.attachments_job_id
      )

      post :create, params: params

      expect(response).to have_http_status(:ok)

      res_body = JSON.parse(response.body)

      expect(res_body['data']).to be_present
      expect(res_body['data']['id']).to eq('')
      expect(res_body['data']['attributes']).to be_present
      expect(res_body['data']['attributes']['confirmation_number']).to eq(submission.carma_case_id)
      expect(res_body['data']['attributes']['submitted_at']).to eq(submission.accepted_at)
    end
  end

  shared_examples 'Form1010cg::Service raising InvalidVeteranStatus' do
    let(:claim) { build(:caregivers_assistance_claim) }
    let(:form_data) { claim.form }
    let(:params) { { caregivers_assistance_claim: { form: form_data } } }
    let(:service) { double }

    it 'renders backend service outage' do
      confirm_new_cg_claim(form_data, claim)

      expect(Raven).to receive(:tags_context).once.with(claim_guid: claim.guid)
      allow(Raven).to receive(:tags_context).with(any_args).and_call_original

      expect(Form1010cg::Service).to receive(:new).with(claim).and_return(service)
      expect(service).to receive(:process_claim!)
        .with(facility_label).and_raise(Form1010cg::Service::InvalidVeteranStatus)

      expect(described_class::AUDITOR).to receive(:record).with(:submission_attempt)
      expect(described_class::AUDITOR).to receive(:record).with(
        :submission_failure_client_qualification,
        claim_guid: claim.guid
      )

      post :create, params: params

      expect(response.status).to eq(503)
      expect(
        JSON.parse(
          response.body
        )
      ).to eq(
        'errors' => [
          {
            'title' => 'Service unavailable',
            'detail' => 'Backend Service Outage',
            'code' => '503',
            'status' => '503'
          }
        ]
      )
    end

    it 'matches the response of a Common::Client::Errors::ClientError' do
      # Two errors are when called in #create and again when error is raised
      expect(Raven).to receive(:tags_context).twice.with(claim_guid: claim.guid)
      allow(Raven).to receive(:tags_context).with(any_args).and_call_original

      ## Backend Client Error Scenario
      confirm_new_cg_claim(form_data, claim)
      expect(Form1010cg::Service).to receive(:new).with(claim).and_return(service)
      expect(service).to receive(:process_claim!)
        .with(facility_label).and_raise(Common::Client::Errors::ClientError)

      backend_client_error_response = post :create, params: params

      # ## Invalid Veteran Status Scenario
      confirm_new_cg_claim(form_data, claim)
      expect(Form1010cg::Service).to receive(:new).with(claim).and_return(service)
      expect(service).to receive(:process_claim!)
        .with(facility_label).and_raise(Form1010cg::Service::InvalidVeteranStatus)
      expect(described_class::AUDITOR).to receive(:record).with(:submission_attempt)
      expect(described_class::AUDITOR).to receive(:record).with(
        :submission_failure_client_qualification,
        claim_guid: claim.guid
      )

      invalid_veteran_status_response = post :create, params: params

      %w[status body headers].each do |response_attr|
        expect(
          invalid_veteran_status_response.send(response_attr)
        ).to eq(
          backend_client_error_response.send(response_attr)
        )
      end
    end
  end

  it 'inherits from ActionController::API' do
    expect(described_class.ancestors).to include(ActionController::API)
  end

  describe '::auditor' do
    it 'is an instance of Form1010cg::Auditor' do
      expect(described_class::AUDITOR).to be_an_instance_of(Form1010cg::Auditor)
    end

    it 'is using Rails.logger' do
      expect(described_class::AUDITOR.logger).to eq(Rails.logger)
    end
  end

  describe '#create' do
    context 'when ezcg_use_facility_api feature toggle is disabled' do
      before do
        Flipper.add :ezcg_use_facility_api
        Flipper.disable :ezcg_use_facility_api
      end

      after do
        Flipper.remove :ezcg_use_facility_api
      end

      it_behaves_like '10-10CG request with missing param: caregivers_assistance_claim', :create
      it_behaves_like '10-10CG request with missing param: form', :create
      it_behaves_like '10-10CG request with invalid form data', :create
      it_behaves_like 'valid service claim', :create
      it_behaves_like 'Form1010cg::Service raising InvalidVeteranStatus', :create
    end

    context 'when ezcg_use_facility_api feature toggle is enabled' do
      before do
        VCR.insert_cassette('pcafc/get_facilities_with_cg_params', allow_unused_http_interactions: true)
        Flipper.add :ezcg_use_facility_api
        Flipper.enable :ezcg_use_facility_api
      end

      after do
        VCR.eject_cassette
        Flipper.remove :ezcg_use_facility_api
      end

      it_behaves_like '10-10CG request with missing param: caregivers_assistance_claim', :create
      it_behaves_like '10-10CG request with missing param: form', :create
      it_behaves_like '10-10CG request with invalid form data', :create
      it_behaves_like 'valid service claim', :create
      it_behaves_like 'Form1010cg::Service raising InvalidVeteranStatus', :create
    end
  end

  describe '#download_pdf' do
    context 'when there is a missing param' do
      it_behaves_like '10-10CG request with missing param: caregivers_assistance_claim', :download_pdf
      it_behaves_like '10-10CG request with missing param: form', :download_pdf
    end

    context 'when ezcg_use_facility_api feature toggle is disabled' do
      before do
        Flipper.add :ezcg_use_facility_api
        Flipper.disable :ezcg_use_facility_api
      end

      after do
        Flipper.remove :ezcg_use_facility_api
      end

      it_behaves_like '10-10CG valid request with pdf', :download_pdf
    end

    context 'when ezcg_use_facility_api feature toggle is enabled' do
      before do
        VCR.insert_cassette('pcafc/get_facilities_with_cg_params', allow_unused_http_interactions: false)
        Flipper.add :ezcg_use_facility_api
        Flipper.enable :ezcg_use_facility_api
      end

      after do
        VCR.eject_cassette
        Flipper.remove :ezcg_use_facility_api
      end

      it_behaves_like '10-10CG valid request with pdf', :download_pdf
    end
  end
end
