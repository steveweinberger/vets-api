# frozen_string_literal: true

require 'saml/ssoe_settings_service'

# rubocop:disable Layout/LineLength

def saml_ssoe_cert_exists?
  !Settings.saml_ssoe.cert_path.nil? && File.file?(File.expand_path(Settings.saml_ssoe.cert_path))
end

def saml_ssoe_key_exists?
  !Settings.saml_ssoe.key_path.nil? && File.file?(File.expand_path(Settings.saml_ssoe.key_path))
end

def new_saml_ssoe_cert_exists?
  !Settings.saml_ssoe.cert_new_path.nil? && File.file?(File.expand_path(Settings.saml_ssoe.cert_new_path))
end

Settings.saml_ssoe.certificate = saml_ssoe_cert_exists? ? File.read(File.expand_path(Settings.saml_ssoe.cert_path)) : nil
Settings.saml_ssoe.key = saml_ssoe_key_exists? ? File.read(File.expand_path(Settings.saml_ssoe.key_path)) : nil
Settings.saml_ssoe.certificate_new = new_saml_ssoe_cert_exists? ? File.read(File.expand_path(Settings.saml_ssoe.cert_new_path)) : nil
Settings.saml_ssoe.idp_metadata = SAML::SSOeSettingsService.parse_idp_metadata

# rubocop:enable Layout/LineLength
