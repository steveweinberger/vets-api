# frozen_string_literal: true

module FastTrack
  class HypertensionMedicationRequestData
    attr_accessor :response

    def initialize(response)
      @response = response
    end

    def transform
      entries = response.body['entry']
      entries.map { |entry| transform_entry(entry) }
    end

    private

    def pick(keys, hash)
      hash.select { |k, _| keys.include? k }.with_indifferent_access
    end

    def transform_entry(raw_entry)
      entry = pick(%w[status medicationReference subject authoredOn note dosageInstruction], raw_entry['resource'])
      result = pick(%w[status authoredOn], entry)
      description_hash = { description: entry['medicationReference']['display'] }
      notes_hash = get_notes_from_note(entry['note'])
      dosage_hash = get_text_from_dosage_instruction(entry['dosageInstruction'])
      result.merge(description_hash, notes_hash, dosage_hash).with_indifferent_access
    end

    def get_notes_from_note(verbose_notes)
      { 'notes': verbose_notes.map { |note| note['text'] } }
    end

    def get_text_from_dosage_instruction(dosage_instructions)
      { 'dosageInstructions': dosage_instructions.map { |instr| instr['text'] } }
    end
  end
end
