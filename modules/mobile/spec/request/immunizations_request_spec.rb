# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'immunizations', type: :request do
  include JsonSchemaMatchers

  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  before do
    allow(File).to receive(:read).and_return(rsa_key.to_s)
    allow_any_instance_of(IAMUser).to receive(:icn).and_return('9000682')
    iam_sign_in(build(:iam_user))
    Timecop.freeze(Time.zone.parse('2021-10-20T15:59:16Z'))
  end

  after { Timecop.return }

  describe 'GET /mobile/v0/health/immunizations' do
    context 'when the expected fields have data' do
      before do
        VCR.use_cassette('lighthouse_health/get_immunizations', match_requests_on: %i[method uri]) do
          get '/mobile/v0/health/immunizations', headers: iam_headers, params: nil
        end
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'matches the expected schema' do
        # TODO: this should use the matcher helper instead (was throwing an Oj::ParseError)
        # expect().to match_json_schema('immunizations')
        expect(response.parsed_body).to eq(
          { 'data' =>
            [{ 'id' => 'I2-A7XD2XUPAZQ5H4Y5D6HJ352GEQ000000',
               'type' => 'immunization',
               'attributes' =>
                { 'cvxCode' => 140,
                  'date' => '2009-03-19T12:24:55Z',
                  'doseNumber' => 'Booster',
                  'doseSeries' => 1,
                  'groupName' => nil,
                  'manufacturer' => nil,
                  'note' =>
                    'Dose #45 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                  'reaction' => 'Vomiting',
                  'shortDescription' =>
                    'Influenza  seasonal  injectable  preservative free' },
               'relationships' => { 'location' => { 'data' => nil, 'links' => { 'related' => nil } } } },
             { 'id' => 'I2-6SIQZNJCIOAQOGES6YOTSQAWJY000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2010-03-25T12:24:55Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #46 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Vomiting',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' => { 'location' => { 'data' => nil, 'links' => { 'related' => nil } } } },
             { 'id' => 'I2-RWRNZDHNNCHLJJKJDJVVVAZHNQ000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2011-03-31T12:24:55Z',
                   'doseNumber' => 'Series 1',
                   'doseSeries' => 1,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #47 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Other',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-4KG3N5YUSPTWD3DAFMLMRL5V5U000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-4KG3N5YUSPTWD3DAFMLMRL5V5U000000' } } } },
             { 'id' => 'I2-YYBTWDMLX6WLFV3GBSIGT5CZO4000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2012-04-05T12:24:55Z',
                   'doseNumber' => 'Booster',
                   'doseSeries' => 1,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #48 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Anaphylaxis or collapse',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-2FPCKUIXVR7RJLLG34XVWGZERM000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-2FPCKUIXVR7RJLLG34XVWGZERM000000' } } } },
             { 'id' => 'I2-LA34JJPECU7NQFSNCRULFSVQ3M000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 113,
                   'date' => '2012-04-05T12:24:55Z',
                   'doseNumber' => 'Booster',
                   'doseSeries' => 1,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #3 of 8 of Td (adult) preservative free vaccine administered.',
                   'reaction' => 'Respiratory distress',
                   'shortDescription' => 'Td (adult) preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-2FPCKUIXVR7RJLLG34XVWGZERM000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-2FPCKUIXVR7RJLLG34XVWGZERM000000' } } } },
             { 'id' => 'I2-DOUHUYLFJLLPSJLACUDAJF5GF4000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2013-04-11T12:24:55Z',
                   'doseNumber' => 'Series 1',
                   'doseSeries' => 2,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #49 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Convulsions',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000' } } } },
             { 'id' => 'I2-VLMNAJAIAEAA3TR34PW5VHUFPM000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2014-04-17T12:24:55Z',
                   'doseNumber' => 'Series 1',
                   'doseSeries' => 2,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #50 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Local reaction or swelling',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000' } } } },
             { 'id' => 'I2-GY27FURWILSYXZTY2GQRNJH57U000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2015-04-23T12:24:55Z',
                   'doseNumber' => 'Series 1',
                   'doseSeries' => 2,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #51 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Vomiting',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-2FPCKUIXVR7RJLLG34XVWGZERM000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-2FPCKUIXVR7RJLLG34XVWGZERM000000' } } } },
             { 'id' => 'I2-F3CW7J5IRY6PVIEVDMRL4R4W6M000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 133,
                   'date' => '2015-04-23T12:24:55Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #1 of 5 of Pneumococcal conjugate PCV 13 vaccine administered.',
                   'reaction' => 'Vomiting',
                   'shortDescription' => 'Pneumococcal conjugate PCV 13' },
               'relationships' => { 'location' => { 'data' => nil, 'links' => { 'related' => nil } } } },
             { 'id' => 'I2-JYYSRLCG3BN646ZPICW25IEOFQ000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2016-04-28T12:24:55Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #52 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Anaphylaxis or collapse',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-2FPCKUIXVR7RJLLG34XVWGZERM000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-2FPCKUIXVR7RJLLG34XVWGZERM000000' } } } },
             { 'id' => 'I2-7PQYOMZCN4FG2Z545JOOLAVCBA000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 33,
                   'date' => '2016-04-28T12:24:55Z',
                   'doseNumber' => 'Series 1',
                   'doseSeries' => 1,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #1 of 1 of pneumococcal polysaccharide vaccine  23 valent vaccine administered.',
                   'reaction' => 'Other',
                   'shortDescription' => 'pneumococcal polysaccharide vaccine  23 valent' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000' } } } },
             { 'id' => 'I2-2ZWOY2V6JJQLVARKAO25HI2V2M000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2017-05-04T12:24:55Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #53 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Fever',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' => { 'location' => { 'data' => nil, 'links' => { 'related' => nil } } } },
             { 'id' => 'I2-NGT2EAUYD7N7LUFJCFJY3C5KYY000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 140,
                   'date' => '2018-05-10T12:24:55Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #54 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
                   'reaction' => 'Respiratory distress',
                   'shortDescription' =>
                     'Influenza  seasonal  injectable  preservative free' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000' } } } },
             { 'id' => 'I2-N7A6Q5AU6W5C6O4O7QEDZ3SJXM000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 207,
                   'date' => '2020-12-18T12:24:55Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #1 of 2 of COVID-19, mRNA, LNP-S, PF, 100 mcg/ 0.5 mL dose vaccine administered.',
                   'reaction' => nil,
                   'shortDescription' => 'COVID-19, mRNA, LNP-S, PF, 100 mcg/ 0.5 mL dose' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000' } } } },
             { 'id' => 'I2-2BCP5BAI6N7NQSAPSVIJ6INQ4A000000',
               'type' => 'immunization',
               'attributes' =>
                 { 'cvxCode' => 207,
                   'date' => '2021-01-14T09:30:21Z',
                   'doseNumber' => nil,
                   'doseSeries' => nil,
                   'groupName' => nil,
                   'manufacturer' => nil,
                   'note' =>
                     'Dose #2 of 2 of COVID-19, mRNA, LNP-S, PF, 100 mcg/ 0.5 mL dose vaccine administered.',
                   'reaction' => nil,
                   'shortDescription' => 'COVID-19, mRNA, LNP-S, PF, 100 mcg/ 0.5 mL dose' },
               'relationships' =>
                 { 'location' =>
                   { 'data' =>
                     { 'id' => 'I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000', 'type' => 'location' },
                     'links' =>
                       { 'related' =>
                         'www.example.com/mobile/v0/health/locations/I2-3JYDMXC6RXTU4H25KRVXATSEJQ000000' } } } }] }
        )
      end

      context 'for items that do not have locations' do
        it 'matches the expected attributes' do
          expect(response.parsed_body['data'].first['attributes']).to eq(
            {
              'cvxCode' => 140,
              'date' => '2009-03-19T12:24:55Z',
              'doseNumber' => 'Booster',
              'doseSeries' => 1,
              'groupName' => nil,
              'manufacturer' => nil,
              'note' => 'Dose #45 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
              'reaction' => 'Vomiting',
              'shortDescription' => 'Influenza  seasonal  injectable  preservative free'
            }
          )
        end

        it 'has a blank relationship' do
          expect(response.parsed_body['data'].first['relationships']).to eq(
            {
              'location' => {
                'data' => nil,
                'links' => {
                  'related' => nil
                }
              }
            }
          )
        end
      end

      context 'for items that do have a location' do
        it 'matches the expected attributes' do
          expect(response.parsed_body['data'][2]['attributes']).to eq(
            {
              'cvxCode' => 140,
              'date' => '2011-03-31T12:24:55Z',
              'doseNumber' => 'Series 1',
              'doseSeries' => 1,
              'groupName' => nil,
              'manufacturer' => nil,
              'note' => 'Dose #47 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
              'reaction' => 'Other',
              'shortDescription' => 'Influenza  seasonal  injectable  preservative free'
            }
          )
        end

        it 'has a relationship' do
          expect(response.parsed_body['data'][2]['relationships']).to eq(
            {
              'location' => {
                'data' => {
                  'id' => 'I2-4KG3N5YUSPTWD3DAFMLMRL5V5U000000',
                  'type' => 'location'
                },
                'links' => {
                  'related' => 'www.example.com/mobile/v0/health/locations/I2-4KG3N5YUSPTWD3DAFMLMRL5V5U000000'
                }
              }
            }
          )
        end
      end
    end

    context 'when the note is null or an empty array' do
      before do
        VCR.use_cassette('lighthouse_health/get_immunizations_blank_note', match_requests_on: %i[method uri]) do
          get '/mobile/v0/health/immunizations', headers: iam_headers, params: nil
        end
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns nil for blank notes' do
        expect(response.parsed_body['data'][0]['attributes']['note']).to be_nil
      end

      it 'returns nil for null notes' do
        expect(response.parsed_body['data'][1]['attributes']['note']).to be_nil
      end

      it 'returns a value for notes that have a value' do
        expect(response.parsed_body['data'][2]['attributes']['note']).to eq(
          'Dose #47 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.'
        )
      end
    end

    describe 'vaccine group name and manufacturer population' do
      let(:immunizations_request) do
        VCR.use_cassette('lighthouse_health/get_immunizations', match_requests_on: %i[method uri]) do
          get '/mobile/v0/health/immunizations', headers: iam_headers, params: nil
        end
      end

      context 'when the vaccine record exists' do
        let!(:vaccine) { create(:vaccine, cvx_code: 140, group_name: 'COVID-19', manufacturer: 'Moderna') }

        it 'uses the vaccine group name and manufacturer in the response' do
          immunizations_request

          expect(response.parsed_body['data'][2]['attributes']).to eq(
            {
              'cvxCode' => 140,
              'date' => '2011-03-31T12:24:55Z',
              'doseNumber' => 'Series 1',
              'doseSeries' => 1,
              'groupName' => vaccine.group_name,
              'manufacturer' => vaccine.manufacturer,
              'note' => 'Dose #47 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
              'reaction' => 'Other',
              'shortDescription' => 'Influenza  seasonal  injectable  preservative free'
            }
          )
        end
      end

      context 'when the vaccine record does not exist' do
        it 'sets group name and manufacturer to nil' do
          immunizations_request

          expect(response.parsed_body['data'][2]['attributes']).to eq(
            {
              'cvxCode' => 140,
              'date' => '2011-03-31T12:24:55Z',
              'doseNumber' => 'Series 1',
              'doseSeries' => 1,
              'groupName' => nil,
              'manufacturer' => nil,
              'note' => 'Dose #47 of 101 of Influenza  seasonal  injectable  preservative free vaccine administered.',
              'reaction' => 'Other',
              'shortDescription' => 'Influenza  seasonal  injectable  preservative free'
            }
          )
        end
      end
    end
  end
end
