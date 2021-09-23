module MPI
  module V1
    class Service
      def initialize
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

      def find_profile(user, search_type = MasterPersonIndex::Constants::CORRELATION_WITH_RELATIONSHIP_DATA)
        if user.mhv_icn.present?
          Raven.tags_context(mvi_find_profile: 'icn')
        elsif user.edipi.present?
          Raven.tags_context(mvi_find_profile: 'edipi')
        end

        @service.find_profile(convert_user(user), search_type)
      end

      private

      def convert_user(user)
        attributes = {}

        %w[
          first_name
          middle_name
          last_name
          birth_date
          ssn
          gender
          mhv_icn
          edipi
        ].each do |attr|
          attributes[attr] = user.public_send(attr)
        end

        MasterPersonIndex::Models::User.new(
          attributes
        )
      end
    end
  end
end
