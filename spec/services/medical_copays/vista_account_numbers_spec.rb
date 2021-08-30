# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MedicalCopays::VistaAccountNumbers do
  subject { described_class.build(data: data) }

  let(:data) do
    {
      '516' => %w[12345 67891234],
      '553' => %w[2 87234689],
      '201' => %w[12345 3624534],
      '205' => %w[4123456 6123],
      '200' => %w[1234 2345678],
      '983' => %w[3234 335678],
      '987' => %w[4234 435678],
      '984' => %w[5234 535678],
      '988' => %w[6234 635678]
    }
  end

  describe 'attributes' do
    it 'responds to data' do
      expect(subject.respond_to?(:data)).to be(true)
    end
  end

  describe '.build' do
    it 'returns an instance of VistaAccountNumbers' do
      expect(subject).to be_an_instance_of(MedicalCopays::VistaAccountNumbers)
    end
  end

  describe '#list' do
    context 'when no data' do
      it 'returns a default list' do
        allow_any_instance_of(MedicalCopays::VistaAccountNumbers).to receive(:data).and_return({})

        expect(subject.list).to eq([0])
      end
    end

    context 'when data' do
      it 'returns an array of Vista Account Numbers' do
        vista_num_list = [
          5160000000012345,
          5160000067891234,
          5530000000000002,
          5530000087234689,
          2010000000012345,
          2010000003624534,
          2050000004123456,
          2050000000006123,
          2000000000001234,
          2000000002345678,
          9830000000003234,
          9830000000335678,
          9870000000004234,
          9870000000435678,
          9840000000005234,
          9840000000535678,
          9880000000006234,
          9880000000635678
        ]

        expect(subject.list).to eq(vista_num_list)
      end
    end
  end

  describe '#vista_account_id' do
    context 'when facility_id plus vista_id is not 16 characters in length' do
      it 'builds the vista_account_id' do
        expect(subject.vista_account_id('4234', '2345678')).to eq(4234000002345678)
      end

      it 'is 16 characters in length' do
        expect(subject.vista_account_id('4234', '2345678').to_s.length).to eq(16)
      end

      it 'adds the appropriate 0s in between' do
        expect(subject.vista_account_id('4234', '2345678').to_s.scan(/0/).length).to eq(5)
      end
    end

    context 'when facility_id plus vista_id is 16 characters' do
      it 'builds the vista_account_id' do
        expect(subject.vista_account_id('423456', '5212345678')).to eq(4234565212345678)
      end

      it 'is 16 characters in length' do
        expect(subject.vista_account_id('423456', '5212345678').to_s.length).to eq(16)
      end

      it 'has no 0s' do
        expect(subject.vista_account_id('423456', '5212345678').to_s.scan(/0/).length).to eq(0)
      end
    end
  end

  describe '#default' do
    it 'returns a default value' do
      expect(subject.default).to eq([0])
    end
  end
end
