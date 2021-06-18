# frozen_string_literal: true

require 'rails_helper'

describe AuditLoginService do
  let(:request_id) { SecureRandom.uuid }

  context 'with new login' do
    context 'when not a valid provider' do
      let(:service) { AuditLoginService.new({'idp' => 'slo'}) }

      subject { service.call }

      it { expect(subject).to be_nil }
    end

    context 'when provider is valid' do

      context 'when idme' do
        let(:service) { AuditLoginService.new('idp' => 'idme', 'request_id' => request_id) }
        subject { service.call }
        it { expect(subject.idp).to eq 'idme' }
        it { expect(subject.request_id).to eq request_id }
      end

      context 'when dslogon' do
        let(:service) { AuditLoginService.new('idp' => 'dslogon', 'request_id' => request_id) }
        subject { service.call }
        it { expect(subject.idp).to eq 'dslogon' }
        it { expect(subject.request_id).to eq request_id }
      end

      context 'when mhv' do
        let(:service) { AuditLoginService.new('idp' => 'mhv', 'request_id' => request_id) }
        subject { service.call }
        it { expect(subject.idp).to eq 'mhv' }
        it { expect(subject.request_id).to eq request_id }
      end
    end
  end

  context 'on SAML callback' do
    let(:saml_response) do
      {
        mvh_id: 123345
      }
    end

    let!(:login_audit) { LoginAudit.create(idp: 'idme', request_id: request_id) }

    context 'with login audit' do
      let(:service) do
        AuditLoginService.new('idp' => 'idme',
          'request_id' => request_id,
          'response' => saml_response)
      end

      subject { service.call }
      it { expect(subject.id).to eq login_audit.id }
      it { expect(subject.response['mhv_id']).to eq saml_response[:mhv_id] }
    end

    context 'without login audit' do
      let(:service) do
        AuditLoginService.new('idp' => 'idme',
          'request_id' => '12333',
          'response' => saml_response)
      end

      subject { service.call }
      it { expect(subject).to be_nil }
    end

  end

end
