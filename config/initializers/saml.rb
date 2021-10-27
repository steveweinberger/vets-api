# frozen_string_literal: true

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

def get_idp_metadata_file
  idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
  settings_file = File.read(Settings.saml_ssoe.idp_metadata_file)
  settings_hash = idp_metadata_parser.parse_to_hash(settings_file)
  settings_url = Settings.saml_ssoe.idp_metadata_url
  url_hash = idp_metadata_parser.parse_remote_to_hash(settings_url)
  if !url_hash.nil? && settings_hash != url_hash
    idp_metadata_parser.parse_remote(settings_url)
    # slack notification/email to dev ops here
  else
    idp_metadata_parser.parse(settings_file)
  end
end

Settings.saml_ssoe.certificate = saml_ssoe_cert_exists? ? File.read(File.expand_path(Settings.saml_ssoe.cert_path)) : nil
Settings.saml_ssoe.key = saml_ssoe_key_exists? ? File.read(File.expand_path(Settings.saml_ssoe.key_path)) : nil
Settings.saml_ssoe.certificate_new = new_saml_ssoe_cert_exists? ? File.read(File.expand_path(Settings.saml_ssoe.cert_new_path)) : nil
Settings.saml_ssoe.idp_metadata = get_idp_metadata_file

# rubocop:enable Layout/LineLength
