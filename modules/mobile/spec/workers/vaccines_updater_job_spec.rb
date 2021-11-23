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
        expect do
          service.perform
        end.to change { Mobile::V0::Vaccine.count }.from(0).to(3)

        no_manufacturer = Mobile::V0::Vaccine.find_by(cvx_code: 1)
        expect(no_manufacturer.group_name).to eq('DTAP')
        covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 207)
        expect(covid_vaccine.group_name).to eq('COVID-19')
        non_covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 110)
        expect(non_covid_vaccine.group_name).to eq('DTAP, HepB')
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
        # manufacturer data is present but it is not a covid-19 vaccine
        non_covid_vaccine = Mobile::V0::Vaccine.find_by(cvx_code: 110)
        expect(non_covid_vaccine.manufacturer).to be_nil
      end
    end
  end

  context 'when vaccine record exists' do
    it 'updates the vaccine' do
      VCR.use_cassette('vaccines/group_names') do
        VCR.use_cassette('vaccines/manufacturers') do
          no_manufacturer = create(:vaccine, cvx_code: 1, group_name: 'FLU', manufacturer: 'Bayer')
          covid_vaccine = create(:vaccine, cvx_code: 207, group_name: 'COVID-19', manufacturer: 'Bayer')
          multiple_groups = create(:vaccine, cvx_code: 110, group_name: 'POLIO', manufacturer: 'Bayer')

          service = described_class.new
          service.perform

          expect(no_manufacturer.reload.manufacturer).to be_nil
          expect(no_manufacturer.group_name).to eq('DTAP')
          expect(covid_vaccine.reload.manufacturer).to eq('Moderna US, Inc.')
          expect(covid_vaccine.group_name).to eq('COVID-19')
          expect(multiple_groups.reload.manufacturer).to be_nil
          expect(multiple_groups.group_name).to eq('DTAP, HepB')
        end
      end
    end
  end

  context 'when the xml is not structured as expected' do
    it 'raises an error' do
      VCR.use_cassette('vaccines/malformed') do
        service = described_class.new
        expect do
          service.perform
        end.to raise_error(Mobile::V0::VaccinesUpdaterJob::VaccinesUpdaterError, 'Property name CVXCode not found')
      end
    end
  end
end
