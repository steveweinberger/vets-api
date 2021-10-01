require 'rails_helper'
require 'mpi/v1/service'

describe MPI::V1::Service do
  let(:user) { create(:user, :loa3).identity }
  let(:service) { described_class.new }
  let(:icn_with_aaid) { '1008714701V416111^NI^200M^USVHA' }
  let(:server_error) { MasterPersonIndex::Responses::FindProfileResponse::RESPONSE_STATUS[:server_error] }
  let(:mvi_profile) do
    build(
      :mpi_profile_response,
      :missing_attrs,
      :address_austin,
      given_names: %w[Mitchell G],
      vha_facility_ids: [],
      vha_facility_hash: nil,
      sec_id: '1008714701',
      birls_id: '796122306',
      birls_ids: ['796122306'],
      historical_icns: nil,
      icn_with_aaid: icn_with_aaid,
      person_types: [],
      full_mvi_ids: [
        '1008714701V416111^NI^200M^USVHA^P',
        '796122306^PI^200BRLS^USVBA^A',
        '9100792239^PI^200CORP^USVBA^A',
        '1008714701^PN^200PROV^USDVA^A',
        '32383600^PI^200CORP^USVBA^L'
      ],
      search_token: nil,
      id_theft_flag: false
    )
  end
  let(:instance) { MasterPersonIndex::Configuration.instance }

  before do
    allow(Settings.mvi).to receive(:pii_logging).and_return(true)
    allow(Settings.mvi).to receive(:mock).and_return(true)
    allow(instance).to receive(:allow_missing_certs?).and_return(true)
  end

  describe 'middlewares' do
    it 'adds middlewares in the right positions' do
      expect(instance.connection.builder.handlers).to eq(
        [
          MasterPersonIndex::Common::Client::Middleware::SOAPHeaders,
          MasterPersonIndex::Common::Client::Middleware::SOAPParser,
          Common::Client::Middleware::Logging,
          Betamocks::Middleware,
          Faraday::Adapter::NetHttp
        ]
      )
    end
  end

  describe '#find_profile' do
    describe '.find_profile with icn', run_at: 'Wed, 21 Feb 2018 20:19:01 GMT' do
      context 'valid requests' do
        it 'fetches profile when icn has ^NI^200M^USVHA^P' do
          allow(user).to receive(:mhv_icn).and_return('1008714701V416111^NI^200M^USVHA^P')

          VCR.use_cassette('mpi/find_candidate/valid_icn_full') do
            profile = mvi_profile
            profile['search_token'] = 'WSDOC1908201553145951848240311'
            expect(Raven).to receive(:tags_context).once.with(mvi_find_profile: 'icn')
            response = subject.find_profile(user)
            expect(response.status).to eq('OK')
            expect(response.profile).to have_deep_attributes(profile)
          end
        end

        it 'fetches profile when icn has ^NI' do
          allow(user).to receive(:mhv_icn).and_return('1008714701V416111^NI')

          VCR.use_cassette('mpi/find_candidate/valid_icn_ni_only') do
            profile = mvi_profile
            profile['search_token'] = 'WSDOC1908201553117051423642755'
            response = subject.find_profile(user)
            expect(response.status).to eq('OK')
            expect(response.profile).to have_deep_attributes(profile)
          end
        end

        it 'fetches profile when icn is just basic icn' do
          allow(user).to receive(:mhv_icn).and_return('1008714701V416111')

          VCR.use_cassette('mpi/find_candidate/valid_icn_without_ni') do
            profile = mvi_profile
            profile['search_token'] = 'WSDOC1908201553094460697640189'
            response = subject.find_profile(user)
            expect(response.status).to eq('OK')
            expect(response.profile).to have_deep_attributes(profile)
          end
        end

        it 'correctly parses vet360 id if it exists', run_at: 'Wed, 21 Feb 2018 20:19:01 GMT' do
          allow(user).to receive(:mhv_icn).and_return('1008787551V609092^NI^200M^USVHA^P')

          VCR.use_cassette('mpi/find_candidate/valid_vet360_id') do
            response = subject.find_profile(user)
            expect(response.status).to eq('OK')
            expect(response.profile['vet360_id']).to eq('80')
          end
        end

        it 'fetches historical icns if they exist', run_at: 'Wed, 21 Feb 2018 20:19:01 GMT' do
          allow(user).to receive(:mhv_icn).and_return('1008787551V609092^NI^200M^USVHA^P')
          allow(SecureRandom).to receive(:uuid).and_return('5e819d17-ce9b-4860-929e-f9062836ebd0')

          match = { match_requests_on: %i[method uri headers body] }
          VCR.use_cassette('mpi/find_candidate/historical_icns_with_icn', match) do
            response = subject.find_profile(user, MPI::Constants::CORRELATION_WITH_ICN_HISTORY)
            expect(response.status).to eq('OK')
            expect(response.profile['historical_icns']).to eq(
              %w[1008692852V724999 1008787550V443247 1008787485V229771 1008795715V162680
                 1008795714V030791 1008795629V076564 1008795718V643356]
            )
          end
        end

        it 'fetches no historical icns if none exist', run_at: 'Wed, 21 Feb 2018 20:19:01 GMT' do
          allow(user).to receive(:mhv_icn).and_return('1008710003V120120^NI^200M^USVHA^P')
          allow(SecureRandom).to receive(:uuid).and_return('5e819d17-ce9b-4860-929e-f9062836ebd0')

          VCR.use_cassette('mpi/find_candidate/historical_icns_empty', VCR::MATCH_EVERYTHING) do
            response = subject.find_profile(user, MPI::Constants::CORRELATION_WITH_ICN_HISTORY)
            expect(response.status).to eq('OK')
            expect(response.profile['historical_icns']).to eq([])
          end
        end

        it 'fetches id_theft flag' do
          allow(user).to receive(:mhv_icn).and_return('1012870264V741864')

          VCR.use_cassette('mpi/find_candidate/valid_id_theft_flag') do
            response = subject.find_profile(user)
            expect(response.status).to eq('OK')
            expect(response.profile['id_theft_flag']).to eq(true)
          end
        end

        it 'returns no errors' do
          allow(user).to receive(:mhv_icn).and_return('1008714701V416111^NI^200M^USVHA^P')

          VCR.use_cassette('mpi/find_candidate/valid_icn_full') do
            response = subject.find_profile(user)

            expect(response.error).to be_nil
          end
        end
      end

      context 'invalid requests' do
        it 'responds with a SERVER_ERROR if ICN is invalid', :aggregate_failures do
          allow(user).to receive(:mhv_icn).and_return('invalid-icn-is-here^NI')
          expect(subject).to receive(:log_exception_to_sentry)

          VCR.use_cassette('mpi/find_candidate/invalid_icn') do
            response = subject.find_profile(user)

            server_error_502_expectations_for(response)
          end
        end

        it 'responds with a SERVER_ERROR if ICN has no matches', :aggregate_failures do
          allow(user).to receive(:mhv_icn).and_return('1008714781V416999')
          expect(subject).to receive(:log_exception_to_sentry)

          VCR.use_cassette('mpi/find_candidate/icn_not_found') do
            response = subject.find_profile(user)

            server_error_502_expectations_for(response)
          end
        end
      end
    end

    describe '.find_profile with edipi', run_at: 'Wed, 21 Feb 2018 20:19:01 GMT' do
      context 'valid requests' do
        it 'fetches profile when no mhv_icn exists but edipi is present' do
          allow(user).to receive(:edipi).and_return('1025062341')

          VCR.use_cassette('mpi/find_candidate/edipi_present') do
            expect(Raven).to receive(:tags_context).once.with(mvi_find_profile: 'edipi')
            response = subject.find_profile(user)
            expect(response.status).to eq('OK')
            expect(response.profile.given_names).to eq(%w[Benjamiin Two])
            expect(response.profile.family_name).to eq('Chesney')
            expect(response.profile.full_mvi_ids).to eq(
              [
                '1061810166V222862^NI^200M^USVHA^P',
                '0000001061810166V222862000000^PI^200ESR^USVHA^A',
                '1025062341^NI^200DOD^USDOD^A',
                'UNK^PI^200BRLS^USVBA^FAULT',
                'UNK^PI^200CORP^USVBA^FAULT'
              ]
            )
          end
        end
      end
    end
  end
end

def server_error_502_expectations_for(response)
  exception = response.error.errors.first

  expect(response.class).to eq MasterPersonIndex::Responses::FindProfileResponse
  expect(response.status).to eq server_error
  expect(response.profile).to be_nil
  expect(exception.title).to eq 'Bad Gateway'
  expect(exception.code).to eq 'MVI_502'
  expect(exception.status).to eq '502'
  expect(exception.source).to eq MPI::V1::Service
end
