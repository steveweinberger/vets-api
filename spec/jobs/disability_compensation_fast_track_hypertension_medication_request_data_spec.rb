# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'
require 'disability_compensation_fast_track_job'

RSpec.describe HypertensionMedicationRequestData do
  subject { described_class }

  describe '#transform' do
    #      it 'returns the expected hash' do
    #        expect(described_class.new(long expected input list here).transform)
    #          .to eq(
    #          long expected results list here
    #          )
    #      end

    it 'returns the expected hash from an empty list' do
      res = OpenStruct.new
      res.body = { 'entry' => [] }
      expect(described_class.new(res).transform)
        .to eq([])
    end

    it 'returns the expected hash from a single-entry list' do
      res = OpenStruct.new
      res.body = {
        'entry' => [
          {
            'fullUrl' => 'https://sandbox-api.va.gov/services/fhir/v0/r4/MedicationRequest/I2-3TCBV3RAFLJW5X23X24CVL4YQE000000',
            'resource' => {
              'resourceType' => 'MedicationRequest',
              'id' => 'I2-3TCBV3RAFLJW5X23X24CVL4YQE000000',
              'status' => 'active',
              'intent' => 'plan',
              'reportedBoolean' => true,
              'medicationReference' => {
                'reference' => 'https://sandbox-api.va.gov/services/fhir/v0/r4/Medication/I2-3KI3RMYAJXTO5ZA6PNEZMJOQMA000000',
                'display' => 'Hydrocortisone 10 MG/ML Topical Cream'
              },
              'subject' => {
                'reference' => 'https://sandbox-api.va.gov/services/fhir/v0/r4/Patient/2000163',
                'display' => 'Mr. Aurelio227 Cruickshank494'
              },
              'authoredOn' => '2009-03-25T01:15:52Z',
              '_requester' => {
                'extension' => [{
                  'url' => 'https://hl7.org/fhir/extension-data-absent-reason.html',
                  'valueCode' => 'unknown'
                }]
              },
              'note' => [{ 'text' => 'Hydrocortisone 10 MG/ML Topical Cream [from note]' }],
              'dosageInstruction' => [{
                'text' => 'Once per day.',
                'timing' => {
                  'repeat' => {
                    'boundsPeriod' => {
                      'start' => '2009-03-25T01:15:52Z'
                    }
                  },
                  'code' => { 'text' => 'As directed by physician.' }
                },
                'route' => { 'text' => 'As directed by physician.' }
              }]
            },
            'search' => { 'mode' => 'match' }
          }
        ]
      }
      expect(described_class.new(res).transform)
        .to match(
          [
            {
              'status': 'active',
              'authoredOn': '2009-03-25T01:15:52Z',
              'description': 'Hydrocortisone 10 MG/ML Topical Cream',
              'notes': ['Hydrocortisone 10 MG/ML Topical Cream [from note]'],
              'dosageInstructions': ['Once per day.']
            }
          ]
        )
    end
  end
end
