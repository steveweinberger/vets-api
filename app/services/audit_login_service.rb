# frozen_string_literal: true

class AuditLoginService

  attr_accessor :request_id, :response, :idp, :login_audit

  def initialize(options={})
    @request_id = options['request_id']
    @response = options.key?('response') ? options['response'] : nil
    @idp = options.key?('idp') ? options['idp'] : nil
  end

  def call
    return nil if response.nil? && !LoginAudit::IDENTITY_PROVIDERS.include?(idp)
    if response.nil?
      create_login_audit
    else
      update_login_audit
    end
    login_audit
  end

  private

  def create_login_audit
    @login_audit = LoginAudit.new(idp: idp,
                                  request_id: request_id)
    login_audit.save
  end

  def update_login_audit
    @login_audit = LoginAudit.find_by(request_id: request_id, idp: idp)
    unless @login_audit.nil?
      login_audit.response = response
      login_audit.save
    end
  end
end
