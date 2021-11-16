# frozen_string_literal: true

require 'rails_helper'

describe LgyService do
  describe '#new' do
    it 'creates a new object of type LgyService' do
      expect(subject).to be_instance_of(LgyService)
    end
  end
end
