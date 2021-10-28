# frozen_string_literal: true

module SAML
  # This class is responsible for putting together a complete ruby-saml
  # SETTINGS object, meaning, our static SP settings + the IDP settings
  # loaded from a file
  module SSOeSettingsService
    class << self
      def saml_settings(options = {})
        settings = base_settings.dup
        options.each do |option, value|
          next if value.nil?

          settings.send("#{option}=", value)
        end
        settings
      end

      def base_settings
        settings = Settings.saml_ssoe.idp_metadata

        if pki_needed?
          settings.certificate = Settings.saml_ssoe.certificate
          settings.private_key = Settings.saml_ssoe.key
          settings.certificate_new = Settings.saml_ssoe.certificate_new
        end
        settings.sp_entity_id = Settings.saml_ssoe.issuer
        settings.assertion_consumer_service_url = Settings.saml_ssoe.callback_url
        settings.compress_request = false

        settings.security[:authn_requests_signed] = Settings.saml_ssoe.request_signing
        settings.security[:want_assertions_signed] = Settings.saml_ssoe.response_signing
        settings.security[:want_assertions_encrypted] = Settings.saml_ssoe.response_encryption
        settings.security[:embed_sign] = false
        settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
        settings
      end

      def pki_needed?
        Settings.saml_ssoe.request_signing || Settings.saml_ssoe.response_encryption
      end

      def parse_idp_metadata_file
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        settings_file = File.read(Settings.saml_ssoe.idp_metadata_file)
        settings_hash = idp_metadata_parser.parse_to_hash(settings_file)
        settings_url = Settings.saml_ssoe.idp_metadata_url
        url_hash = idp_metadata_parser.parse_remote_to_hash(settings_url)

        parsed_metadata = idp_metadata_parser.parse(settings_file)
        hash_diff = generate_saml_hash_diff(url_hash, settings_hash)
        if !url_hash.nil? && hash_diff
          parsed_metadata = idp_metadata_parser.parse_remote(settings_url)
          notify_slack(hash_diff) if %w[development staging production].include? Settings.vsp_environment
        end
        parsed_metadata
      end

      def generate_saml_hash_diff(url_hash, settings_hash)
        hash_diff = {}
        url_hash.each_pair do |key, value|
          hash_diff[key] = value if value != settings_hash[key]
        end
        hash_diff
      end

      def notify_slack(hash_diff)
        client = SlackNotify::Client.new(
          webhook_url: Settings.saml_ssoe.slack.webhook_url,
          channel: '#vsp-identity',
          username: "Identity - #{Settings.vsp_environment}"
        )
        message = 'Discrepancy detected between local and remote SAML IDP metadata settings.'
        message += "Detected differences: #{hash_diff}"
        client.notify(message)
      end
    end
  end
end
