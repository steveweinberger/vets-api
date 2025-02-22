# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Preneeds Burial Form Integration' do
  include SchemaMatchers

  let(:params) do
    { application: attributes_for(:burial_form) }
  end

  def post_burial_forms(additional_headers = {})
    post '/v0/preneeds/burial_forms',
         params: params.to_json,
         headers: { 'CONTENT_TYPE' => 'application/json' }.merge(additional_headers)
  end

  context 'with valid input' do
    it 'responds to POST #create' do
      VCR.use_cassette('preneeds/burial_forms/creates_a_pre_need_burial_form') do
        post_burial_forms
      end

      expect(response).to be_successful
      expect(response.body).to be_a(String)
      expect(response).to match_response_schema('preneeds/receive_applications')
    end

    it 'responds to POST #create when camel-inflected' do
      VCR.use_cassette('preneeds/burial_forms/creates_a_pre_need_burial_form') do
        post_burial_forms({ 'X-Key-Inflection' => 'camel' })
      end

      expect(response).to be_successful
      expect(response.body).to be_a(String)
      expect(response).to match_camelized_response_schema('preneeds/receive_applications')
    end

    it 'clears the saved form' do
      expect_any_instance_of(ApplicationController).to receive(:clear_saved_form).with('40-10007').once
      VCR.use_cassette('preneeds/burial_forms/creates_a_pre_need_burial_form') do
        post_burial_forms
      end
    end
  end

  context 'with invalid input' do
    it 'returns an with error' do
      params[:application][:veteran].delete(:military_status)
      post_burial_forms

      error = JSON.parse(response.body)['errors'].first

      expect(error['status']).to eq('422')
      expect(error['title']).to match(/validation error/i)
      expect(error['detail']).to match(/militaryStatus/)
    end

    it 'does not clear the saved form' do
      expect_any_instance_of(ApplicationController).not_to receive(:clear_saved_form).with('40-10007')

      params[:application][:veteran].delete(:military_status)
      post_burial_forms
    end
  end

  context 'with a failed burial form submittal from EOAS' do
    it 'returns with a VA900 error when status is 500' do
      VCR.use_cassette('preneeds/burial_forms/burial_form_with_invalid_applicant_address2') do
        params[:application][:applicant][:mailing_address][:address2] = '1' * 21
        post_burial_forms
      end

      error = JSON.parse(response.body)['errors'].first

      expect(error['status']).to eq('400')
      expect(error['title']).to match(/operation failed/i)
      expect(error['detail']).to match(/Error committing transaction/i)
    end

    it 'returns with a VA900 error when the status is 200' do
      VCR.use_cassette('preneeds/burial_forms/burial_form_with_duplicate_tracking_number') do
        allow_any_instance_of(Preneeds::BurialForm).to receive(:generate_tracking_number).and_return('19')
        post_burial_forms
      end

      error = JSON.parse(response.body)['errors'].first

      expect(error['status']).to eq('400')
      expect(error['title']).to match(/operation failed/i)
      expect(error['detail']).to match(/Tracking number '19' already exists/i)
    end

    it 'does not clear the saved form' do
      expect_any_instance_of(ApplicationController).not_to receive(:clear_saved_form).with('40-10007')

      VCR.use_cassette('preneeds/burial_forms/burial_form_with_duplicate_tracking_number') do
        allow_any_instance_of(Preneeds::BurialForm).to receive(:generate_tracking_number).and_return('19')
        post_burial_forms
      end
    end
  end

  describe 'tracking burial form submissions' do
    let(:submission_record) { ::Preneeds::PreneedSubmission.first }
    let(:response_json) { JSON.parse(response.body)['data']['attributes'] }

    context 'with successful submission' do
      it 'creates a PreneedSubmission record' do
        VCR.use_cassette('preneeds/burial_forms/creates_a_pre_need_burial_form') do
          expect do
            post_burial_forms
          end.to change { ::Preneeds::PreneedSubmission.count }.by(1)
        end

        expect(response_json['tracking_number']).to eq(submission_record.tracking_number)
        expect(response_json['application_uuid']).to eq(submission_record.application_uuid)
        expect(response_json['return_code']).to eq(submission_record.return_code)
        expect(response_json['return_description']).to eq(submission_record.return_description)
      end
    end
  end
end
