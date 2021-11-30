# frozen_string_literal: true

require 'rails_helper'
require 'pdf_fill/forms/va21526ez'

def basic_class
  PdfFill::Forms::Va21526ez.new({})
end

describe PdfFill::Forms::Va21526ez do
  include SchemaMatchers

  let(:form_data) do
    get_fixture('pdf_fill/21-526EZ/kitchen_sink')
  end

  let(:default_account) do
    { 'name' => 'None', 'amount' => 0, 'recipient' => 'None' }
  end

  let(:default_additional_account) do
    {
      'additionalSourceName' => 'None',
      'amount' => 0,
      'recipient' => 'None',
      'sourceAndAmount' => 'None: $0'
    }
  end
end
