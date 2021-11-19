# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mobile::V0::Vaccine, type: :model do
  describe '#add_group_name' do
    it 'sets the group name when none is present' do
      vaccine = build(:vaccine, group_name: nil)
      vaccine.add_group_name('ebola')
      expect(vaccine.group_name).to eq('ebola')
    end

    it 'adds the incoming group name when it is not included in the current group name' do
      vaccine = build(:vaccine, group_name: 'FLU')
      vaccine.add_group_name('ebola')
      expect(vaccine.group_name).to eq('FLU, ebola')
    end

    it 'does not add the incoming group name when it is already included' do
      vaccine = build(:vaccine, group_name: 'FLU')
      vaccine.add_group_name('FLU')
      expect(vaccine.group_name).to eq('FLU')
    end
  end
end