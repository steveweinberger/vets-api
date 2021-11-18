# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mobile::V0::VaccinesUpdaterJob, type: :job do
  GROUP_NAME_XML = 'https://www2.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=vax2vg'
  MANUFACTURER_XML = 'https://www2a.cdc.gov/vaccines/iis/iisstandards/XML.asp?rpt=tradename'

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  it "creates vaccine records" do
    VCR.use_cassette('vaccines/vaccine_xml') do
      service = described_class.new
      expect {
        Sidekiq::Testing.inline! { service.perform }
      }.to change { Mobile::V0::Vaccine.count }.from(0).to(171)
    end
  end
end