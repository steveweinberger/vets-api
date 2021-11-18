# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mobile::V0::VaccinesUpdaterJob, type: :job do
  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  it 'creates records for all vaccines in the group_names xml' do
    VCR.use_cassette('vaccines/group_names') do
      VCR.use_cassette('vaccines/manufacturers') do
        service = described_class.new
        expect {
          service.perform
        }.to change { Mobile::V0::Vaccine.count }.from(0).to(3)

        no_manufacturer = Mobile::V0::Vaccine.find_by(cvx_code: 1)
        expect(no_manufacturer.group_name).to eq('DTAP')
        covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 207)
        expect(covid_vaccine.group_name).to eq('COVID-19')
        non_covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 2)
        expect(non_covid_vaccine.group_name).to eq('POLIO')
      end
    end
  end

  it 'sets manufacturer when manufacturer data is available and group name is COVID-19' do
    VCR.use_cassette('vaccines/group_names') do
      VCR.use_cassette('vaccines/manufacturers') do
        service = described_class.new
        service.perform

        # no manufacturer data is present in the xml for this record
        no_manufacturer = Mobile::V0::Vaccine.find_by(cvx_code: 1)
        expect(no_manufacturer.manufacturer).to be_nil
        covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 207)
        expect(covid_vaccine.manufacturer).to eq('Moderna US, Inc.')
        # manufacturer data is present for this record
        non_covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 2)
        expect(non_covid_vaccine.manufacturer).to be_nil
      end
    end
  end

  it 'updates records that have changed' do
    VCR.use_cassette('vaccines/group_names') do
      VCR.use_cassette('vaccines/manufacturers') do
        no_manufacturer = create(:mobile_vaccine, cvx_code: 1, group_name: 'CANDY BARS', manufacturer: 'Hershey')
        covid_vaccine = create(:mobile_vaccine, cvx_code: 207, group_name: 'CANDY BARS', manufacturer: nil)
        non_covid_vaccine = create(:mobile_vaccine, cvx_code: 2, group_name: 'CANDY BARS', manufacturer: 'Mars')

        service = described_class.new
        expect {
          service.perform
        }.not_to change { Mobile::V0::Vaccine.count }

        expect(no_manufacturer.reload.group_name).to eq('DTAP')
        expect(no_manufacturer.manufacturer).to be_nil
        expect(covid_vaccine.reload.group_name).to eq('COVID-19')
        expect(covid_vaccine.manufacturer).to eq('Moderna US, Inc.')
        expect(non_covid_vaccine.reload.group_name).to eq('POLIO')
        expect(non_covid_vaccine.manufacturer).to be_nil
      end
    end
  end
end