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

Settings.saml_ssoe.certificate = saml_ssoe_cert_exists? ? File.read(File.expand_path(Settings.saml_ssoe.cert_path)) : nil
Settings.saml_ssoe.key = saml_ssoe_key_exists? ? File.read(File.expand_path(Settings.saml_ssoe.key_path)) : nil
Settings.saml_ssoe.certificate_new = new_saml_ssoe_cert_exists? ? File.read(File.expand_path(Settings.saml_ssoe.cert_new_path)) : nil
Settings.saml_ssoe.idp_metadata = parse_idp_metadata_file

# rubocop:enable Layout/LineLength
