# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestUserDashboard::ApplicationController, type: :controller do
  controller do
    def index; end
  end

  describe 'authenticate!' do
    before do
      allow_any_instance_of(described_class).to receive(:authenticated?) { true }
    end

    subject do
      controller.authenticate!
    end

    it 'returns true for an authenticated user' do
      expect(subject).to be_nil
    end
  end

  describe '#authorize!' do
    before do
      allow_any_instance_of(described_class).to receive(:authorized?) { true }
    end

    subject do
      controller.authorize!
    end

    it "returns true" do
      expect(subject).to be_truthy
    end
  end

  describe '#authorized?' do
    let!(:user_details) { 'test user details'}

    context 'authenticated user' do
      before do
        allow_any_instance_of(described_class).to receive(:authenticated?) { true }
        allow_any_instance_of(described_class).to receive_message_chain(:github_user, :organization_member?) { true }
        allow_any_instance_of(described_class).to receive(:github_user_details) { user_details }
      end
  
      subject do
        controller.authorized?
      end
  
      it 'logs the GitHub user details' do
        expect(Rails.logger).to receive(:info).with("TUD authorization successful: #{user_details}")
        subject
      end
  
      it 'returns true' do
        expect(subject).to be_truthy
      end
    end

    context 'unauthenticated user' do
      before do
        allow_any_instance_of(described_class).to receive(:authenticated?) { false }
      end

      subject do
        controller.authorized?
      end
  
      it 'returns false' do
        expect(subject).to be_falsey
      end
    end
  end

  describe '#github_user_details' do
    before do
      allow_any_instance_of(described_class).to receive_message_chain(:github_user, :id) { 1 }
      allow_any_instance_of(described_class).to receive_message_chain(:github_user, :login) { 'tedlasso' }
      allow_any_instance_of(described_class).to receive_message_chain(:github_user, :name) { 'Ted Lasso' }
      allow_any_instance_of(described_class).to receive_message_chain(:github_user, :email) { 'ted.lasso@richmond.co.uk' }    
    end

    subject do
      controller.github_user_details
    end

    it "returns a string containing the user's github information" do
      expect(subject).to eq('ID: 1, Login: tedlasso, Name: Ted Lasso, Email: ted.lasso@richmond.co.uk')
    end
  end
end
