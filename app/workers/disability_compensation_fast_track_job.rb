# frozen_string_literal: true

require 'prawn'
require 'lighthouse/veterans_health/client'

class DisabilityCompensationFastTrackJob
  include Sidekiq::Worker
  extend SentryLogging
  sidekiq_options retry: 14

  def perform(form526_submission_id)
    # submission = Form526Submission.find(form526_submission_id)
    # icn = Account.where(idme_uuid: submission.user_uuid).first.icn
    #temporary below
    icn = 2000163
    client = Lighthouse::VeteransHealth::Client.new
    # TODO: rescue !=200 responses with an appropriate action
    condition_response = client.get_request('conditions', icn)
    return unless is_hypertension?(condition_response)
    # TODO: rescue !=200 responses with an appropriate action
    results = HypertensionObservationData.new(observations_response).transform
    observations_response = client.get_request('observations', icn)
    # entries = observations_response.body.dig('entry')
    # results = entries.map {|entry| transform_entry(entry)}

    # pdf_body = generate_pdf(condition_response)
    # client = EVSS::DocumentsService.new(submission.auth_headers)
    # client.upload(pdf_body, create_document_data(upload_data))
  end


  def is_hypertension?(condition_response)
    condition_response.body['entry'].each { |e| return true if e['resource']['code']['text'].downcase == 'hypertension' }
  end

  def generate_pdf(_condition_response)
    # Prawn documentation - https://prawnpdf.org/manual.pdf
    # todo: do something with lighthouse response to put in PDF
    pdf = Prawn::Document.new
    pdf.text 'Hello World!'
    pdf.define_grid(columns: 5, rows: 8, gutter: 10)
    pdf.render
  end

  def create_document_data(submission)
    # 'L048' => 'Medical Treatment Record - Government Facility',
    EVSSClaimDocument.new(
      evss_claim_id: submission.submitted_claim_id,
      file_name: 'hypertension_evidence.pdf',
      tracked_item_id: nil,
      document_type: 'L048'
    )
  end
end

# What should the DisabilityCompensationFastTrackJob class do, as opposed to helper class(es).
# 1. Get the conditions data about the claim.
# 2. If conditions data does not match hypertension, do nothing.
# 3. Otherwise: call LH for more data to get BP and medication data; parse that data; shape that data; generate a PDF from that data; attach PDF to EVSS; attach special issue (RRD) to EVSS claim; submit EVSS claim. (Not in that order necessarily)
# Helper classes to:
# - parse LH API call, shape, return it.

class HypertensionObservationData
  attr_accessor :response

  def initialize(response)
    @response = response
  end

  def transform
    entries = response.body.dig('entry')
    entries.map {|entry| transform_entry(entry)}
  end

  private

  def pick(keys, hash)
    result = hash.select {|k, v| keys.include? k}
    return result
  end

  def transform_entry(raw_entry)
    # TODO: DO we need to verify LOINC code 85354-9 here as well?
    # TODO: I'm using issued here over effectiveDateTime, is that correct?
    entry = pick(["issued", "component", "performer"], raw_entry["resource"])
    result = {"issued": entry["issued"]}
    practitioner_hash = get_display_hash_from_performer("Practitioner", entry)
    organization_hash = get_display_hash_from_performer("Organization", entry)
    bp_hash = get_bp_readings_from_entry(entry)
    result = result.merge(practitioner_hash, organization_hash, bp_hash)
    return result
  end

  def get_display_hash_from_performer(term, entry)
    result = {}
    performer = entry["performer"].select {|item| item["reference"].include? term}.first
    if performer.present?
      result[term.downcase.to_sym] = performer["display"]
    end
    return result

  end

  def get_bp_readings_from_entry(entry)
    
    result = {}
    # Each component should contain a BP pair, so after filtering there should only be one reading of each type:
    systolic = filter_components_by_code("8480-6", entry["component"]).first
    diastolic = filter_components_by_code("8462-4", entry["component"]).first

    if systolic.blank? || diastolic.blank?
      # TODO: unlike the above error, I do think we need this one, because if
      # either are missing from the entry I don't think we can use it.
      # However, it's possible that there may be entire entries that we could
      # skip if we still got some valid entries, so again I'm not certain that
      # raising an error here is correct.
      raise "missing systolic or diastolic"
    else
      result[:systolic] = extract_bp_data_from_component(systolic)
      result[:diastolic] = extract_bp_data_from_component(diastolic)
      # result[:diastolic] = diastolic
    end

    return result

  end

  def filter_components_by_code(code, components)
    # Filter the components to only those that have at least one code.coding element with the code:
    matches = components.filter {|item| item["code"]["coding"].filter {|el| el["code"] == code}.length >0}
    # Filter the code.coding list to only have elements matching the code:
    matches.map {|match| match["code"]["coding"] = match["code"]["coding"].filter {|el| el["code"] == code}}
    return matches
  end

  def extract_bp_data_from_component(component)
    # component.code.coding, since we've filtered it down in filter_components_by_code,
    # should only the coding we expect, and since if there were multiples for some odd
    # reason the values in them would all be the same, we can just take the first one.
    coding = pick(["code", "display"], component["code"]["coding"].first)
    # The values we want are all in component.valueQuantity
    values = pick(["unit", "value"], component["valueQuantity"])
    data = coding.merge(values)
    return data
  end

end

