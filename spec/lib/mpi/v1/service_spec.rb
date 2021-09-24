require 'rails_helper'
require 'mpi/v1/service'

describe MPI::V1::Service do
  let(:user) { create(:user, :loa3) }
  let(:service) { described_class.new }
  let(:icn_with_aaid) { '1008714701V416111^NI^200M^USVHA' }
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

  before do
    instance = MasterPersonIndex::Configuration.instance
    allow(instance).to receive(:allow_missing_certs?).and_return(true)
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
