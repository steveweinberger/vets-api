# frozen_string_literal: true

require 'authentication_system_helper'

if ENV['LOGIN_SYSTEM_TESTS']
  RSpec.describe 'DS Logon login', type: :system do
    context 'LOA2 premium' do
      include_examples 'logs in DS Logon LOA2 user', 'ace.a.mcghee1'
      include_examples 'logs in DS Logon LOA2 user', 'ardeshir.t.caulder1'
      include_examples 'logs in DS Logon LOA2 user', 'marti.c.ortizrivera1'
    end
  end
end
