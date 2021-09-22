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
          service.find_profile(user)
        end
      end
    end
  end
end
