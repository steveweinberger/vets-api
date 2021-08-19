# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MedicalCopays::VBS::RequestData do
  subject { described_class.build(user: user) }

  let(:user) { build(:user, :loa3) }

  describe 'attributes' do
    it 'responds to user' do
      expect(subject.respond_to?(:user)).to be(true)
    end

    it 'responds to edipi' do
      expect(subject.respond_to?(:edipi)).to be(true)
    end

    it 'responds to vista_account_numbers' do
      expect(subject.respond_to?(:vista_account_numbers)).to be(true)
    end
  end

  describe '.build' do
    it 'returns an instance of Service' do
      expect(subject).to be_an_instance_of(MedicalCopays::VBS::RequestData)
    end
  end

  describe '#to_hash' do
    it 'returns a data hash' do
      allow(user).to receive(:edipi).and_return('123')
      allow_any_instance_of(MedicalCopays::VBS::RequestData).to receive(:vista_account_numbers)
        .and_return([])

      expect(subject.to_hash).to eq({ edipi: '123', vistaAccountNumbers: [] })
    end
  end

  describe '#valid?' do
    context 'when no errors' do
      it 'returns true' do
        allow(user).to receive(:edipi).and_return('123')
        allow_any_instance_of(MedicalCopays::VBS::RequestData).to receive(:vista_account_numbers)
          .and_return([])

        expect(subject.valid?).to be(true)
      end
    end

    context 'when errors' do
      it 'returns false' do
        allow(user).to receive(:edipi).and_return(1)
        allow_any_instance_of(MedicalCopays::VBS::RequestData).to receive(:vista_account_numbers)
          .and_return({})

        expect(subject.valid?).to be(false)
      end
    end
  end

  describe '#statements_schema' do
    it 'has a fixed statements_schema hash' do
      hsh = {
        'type' => 'object',
        'additionalProperties' => false,
        'required' => %w[edipi vistaAccountNumbers],
        'properties' => {
          'edipi' => {
            'type' => 'string'
          },
          'vistaAccountNumbers' => {
            'type' => 'array',
            'items' => {
              'type' => 'string',
              'minLength' => 16,
              'maxLength' => 16
            }
          }
        }
      }

      expect(subject.class.statements_schema).to eq(hsh)
    end
  end

  describe '#schema_validation_options' do
    it 'has a fixed schema_validation_options hash' do
      hsh = {
        errors_as_objects: true,
        version: :draft6
      }

      expect(subject.class.schema_validation_options).to eq(hsh)
    end
  end
end