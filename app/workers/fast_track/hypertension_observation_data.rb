# frozen_string_literal: true

module FastTrack
  class HypertensionObservationData
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
      entry = pick(%w[issued component performer], raw_entry['resource'])
      result = { issued: entry['issued'] }
      practitioner_hash = get_display_hash_from_performer('Practitioner', entry)
      organization_hash = get_display_hash_from_performer('Organization', entry)
      bp_hash = get_bp_readings_from_entry(entry)
      result.merge(practitioner_hash, organization_hash, bp_hash)
    end

    def get_display_hash_from_performer(term, entry)
      result = {}
      if entry['performer'].present?
        performer_with_term = entry['performer'].select { |item| item['reference'].include? term }
        result[term.downcase.to_sym] = performer_with_term.first['display'] if performer_with_term.present?
      end
      result
    end

    def get_bp_readings_from_entry(entry)
      result = {}
      # Each component should contain a BP pair, so after filtering there should only be one reading of each type:
      systolic = filter_components_by_code('8480-6', entry['component']).first
      diastolic = filter_components_by_code('8462-4', entry['component']).first

      if systolic.blank? || diastolic.blank?
        # TODO: if either are missing from the entry I don't think we can use
        # it. However, it's possible that there may be entire entries that we
        # could skip if we still got some valid entries, so again I'm not certain
        # that raising an error here is correct.
        raise 'missing systolic or diastolic'
      else
        result[:systolic] = extract_bp_data_from_component(systolic)
        result[:diastolic] = extract_bp_data_from_component(diastolic)
      end

      result
    end

    def filter_components_by_code(code, components)
      # Filter the components to only those that have at least one code.coding element with the code:
      matches = components.filter { |item| item['code']['coding'].filter { |el| el['code'] == code }.length.positive? }
      # Filter the code.coding list to only have elements matching the code:
      matches.map { |match| match['code']['coding'] = match['code']['coding'].filter { |el| el['code'] == code } }
      matches
    end

    def extract_bp_data_from_component(component)
      # component.code.coding, since we've filtered it down in filter_components_by_code,
      # should only the coding we expect, and since if there were multiples for some odd
      # reason the values in them would all be the same, we can just take the first one.
      coding = pick(%w[code display], component['code']['coding'].first)
      # The values we want are all in component.valueQuantity
      values = pick(%w[unit value], component['valueQuantity'])
      coding.merge(values)
    end
  end
end