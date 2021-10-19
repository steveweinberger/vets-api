# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestUserDashboard::ApplicationController, type: :controller do
  controller do
    def index; end
  end

  # methods to test:
  # authenticate!
  # authorize!
  # authorized?
  # github_user_details - done

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