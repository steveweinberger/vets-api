require 'rails_helper'
require 'mpi/v1/service'

describe MPI::V1::Service do
  let(:user) { create(:user, :loa3) }
  let(:service) { described_class.new }

  before do
    instance = MasterPersonIndex::Configuration.instance
    allow(instance).to receive(:allow_missing_certs?).and_return(true)
  end

  describe '#find_profile' do
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
