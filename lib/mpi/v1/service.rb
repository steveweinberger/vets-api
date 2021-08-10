module MPI
  module V1
    class Service
      def initialize(user)
        @user = user
        @service = MasterPersonIndex::Service.new

        instance = MasterPersonIndex::Configuration.instance

        instance.base_path = Settings.mvi.url
        instance.ssl_cert_path = Settings.mvi.client_cert_path
        instance.ssl_key_path = Settings.mvi.client_key_path
        instance.open_timeout = Settings.mvi.open_timeout
        instance.read_timeout = Settings.mvi.timeout
        instance.processing_code = Settings.mvi.processing_code
        instance.vba_orchestration = Settings.mvi.vba_orchestration
        instance.edipi_search = Settings.mvi.edipi_search
      end
    end
  end
end
