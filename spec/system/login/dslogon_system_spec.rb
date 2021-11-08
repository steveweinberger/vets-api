# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'DS Logon login', type: :system do
    context 'outbound' do
      context 'LOA2 premium' do
        include_examples 'logs in outbound DS Logon user', 'ace.a.mcghee1', ENV['DSLOGON_LOA2_PASSWORD']
        include_examples 'logs in outbound DS Logon user', 'ardeshir.t.caulder1', ENV['DSLOGON_LOA2_PASSWORD']
        include_examples 'logs in outbound DS Logon user', 'marti.c.ortizrivera1', ENV['DSLOGON_LOA2_PASSWORD']
      end
    end

    context 'inbound' do
      context 'LOA2 premium' do
        include_examples 'logs in inbound DS Logon user from eauth', 'ace.a.mcghee1', ENV['DSLOGON_LOA2_PASSWORD']
        include_examples 'logs in inbound DS Logon user from eauth', 'ardeshir.t.caulder1', ENV['DSLOGON_LOA2_PASSWORD']
        include_examples 'logs in inbound DS Logon user from eauth', 'marti.c.ortizrivera1', ENV['DSLOGON_LOA2_PASSWORD']
      end
    end
  end
end
