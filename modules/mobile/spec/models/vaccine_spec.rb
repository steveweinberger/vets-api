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

    it 'returns the group name and does not save the record' do
      vaccine = build(:vaccine, group_name: 'Flu')
      group_name = vaccine.add_group_name('ebola')
      expect(group_name).to eq('Flu, ebola')
      expect(vaccine.persisted?).to eq(false)
    end
  end
end
