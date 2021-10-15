# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authenticating through ID.me', type: :request, js: true do
  context 'loa1 user' do
    it 'will authenticate user successfully' do
      get '/v1/sessions/idme/new'
      expect(response).to have_http_status(:ok)

      doc = Nokogiri::HTML(body)
      form = doc.at_css('[id="saml-form"]')

      url = form.attributes['action'].value
      form_inputs = form.children.select { |child| child.name == 'input' }

      post form.attributes['action'].value, params:
    end
  end
end
