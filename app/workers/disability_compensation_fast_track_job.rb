# frozen_string_literal: true

require 'prawn'
require 'prawn/table'
require 'lighthouse/veterans_health/client'

class DisabilityCompensationFastTrackJob
  include Sidekiq::Worker

  extend SentryLogging
  #TODO this needs to be thought about more. How many retries and how long do we want this to attempt.
  sidekiq_options retry: 14

  def perform(form526_submission_id, full_name)
    submission = Form526Submission.find(form526_submission_id)
    icn = Account.where(idme_uuid: submission.user_uuid).first.icn

    client = Lighthouse::VeteransHealth::Client.new(icn)
    observations_response = client.get_resource('observations')
    medicationrequest_response = client.get_resource('medications')

    bpreadings = HypertensionObservationData.new(observations_response).transform
    return if no_recent_bp_readings(bpreadings)

    medications = HypertensionMedicationRequestData.new(medicationrequest_response).transform

    patient = nil # TODO: change when we know how to get patient
    bpreadings = bpreadings.filter { |reading| reading[:issued].to_date > 1.year.ago }
    bpreadings = bpreadings.sort_by { |reading| reading[:issued].to_date }.reverse!
    medications = medications.sort_by { |med| med[:authoredOn].to_date }.reverse!
    pdf = HypertensionPDFGenerator.new(full_name, bpreadings, medications, Date.today).generate
    pdf_body = pdf.render


    # Upload the file to S3 through the SupportingEvidenceAttachment class
    supporting_evidence_attachment = SupportingEvidenceAttachment.new
    file = FileIO.new(pdf_body, 'hypertension_evidence.pdf')
    supporting_evidence_attachment.set_file_data!(file)

    # TODO: move below two lines and the HypertensionSpecialIssueManager class
    # so that the pdf is being uploaded within the submission model instance,
    # wherever the rest of the EVSS Document Service uploads are being done.
    # evss_client = EVSS::DocumentsService.new(submission.auth_headers)
    # evss_client.upload(pdf_body, create_document_data(submission))

    HypertensionSpecialIssueManager.new(submission).add_special_issue
  end

  private

  def no_recent_bp_readings(bp_readings)
    last_reading = bp_readings.map { |reading| reading[:issued] }.sort.last
    last_reading < 1.year.ago
  end

  def hypertension?(condition_response)
    #TODO this is not how this should work
    #We need to check for ANY bp readings in the last year regardless of the presence of hypertension as the condition in lh.
    condition_response.body['entry'].filter do |entry| 
      entry['resource']['code']['text'].downcase == 'hypertension' &&
        entry['resource']['clinicalStatus']['text'].downcase == 'active'
    end.length.positive?
  end

  def create_document_data(submission)
    # 'L048' => 'Medical Treatment Record - Government Facility',
    # TODO: determine whether or not there's a 'subject' field we can set and
    # what it should be.
    # file name should be this text and dynamic date range 'VAMC Hypertension Rapid Decision Evidence [date range]'
    # Date range format = 11/08/202 - 11/08/2021
    EVSSClaimDocument.new(
      evss_claim_id: submission.submitted_claim_id,
      file_name: 'hypertension_evidence.pdf', # TODO: change this to what Emily wants the filename to be.
      tracked_item_id: nil,
      document_type: 'L048' # Double-check with Zach (and/or Emily) as to what this should be.
    )
  end
end

class FileIO < StringIO
  def initialize(stream, filename)
    super(stream)
    @original_filename = filename
    @fast_track = true
    @content_type = 'application/pdf'
  end

  attr_reader :content_type, :original_filename, :fast_track
end

# What should the DisabilityCompensationFastTrackJob class do, as opposed to helper class(es).
# 1. Get the conditions data about the claim.
# 2. If conditions data does not match hypertension, do nothing.
# 3. Otherwise: call LH for more data to get BP and medication data;
#    parse that data;
#    shape that data;
#    generate a PDF from that data;
#    attach PDF to EVSS;
#    attach special issue (RRD) to EVSS claim;
#    submit EVSS claim. (Not in that order necessarily)
# Helper classes to:
# - parse LH API call, shape, return it.

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
    # TODO: DO we need to verify LOINC code 85354-9 here as well?
    # TODO: I'm using issued here over effectiveDateTime, is that correct?
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
      # TODO: unlike the above error, I do think we need this one, because if
      # either are missing from the entry I don't think we can use it.
      # However, it's possible that there may be entire entries that we could
      # skip if we still got some valid entries, so again I'm not certain that
      # raising an error here is correct.
      raise 'missing systolic or diastolic'
    else
      result[:systolic] = extract_bp_data_from_component(systolic)
      result[:diastolic] = extract_bp_data_from_component(diastolic)
      # result[:diastolic] = diastolic
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
    # TODO: I'm using authoredOn here over boundsPeriod.start, is that correct?
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

class HypertensionPDFGenerator
  attr_accessor :patient, :bp_data, :medications

  def initialize(patient, bp_data, medications, date)
    @patient = patient
    @bp_data = bp_data
    @medications = medications
    @date = date
  end

  def generate
    pdf = Prawn::Document.new
    pdf = add_intro(pdf)
    pdf = add_blood_pressure(pdf)
    pdf = add_medications(pdf) if medications.length > 1
    pdf = add_about(pdf)
    pdf
  end

  def stringify_patient
    suffix = @patient[:suffix].present? ? ", #{patient[:suffix]}" : ""
    stringified = ""
    [:first, :middle, :last].each do |name|
      if @patient[name].present?
        stringified = "#{stringified} #{@patient[name]}"
      end
    end

    stringified = "#{stringified}#{suffix}"
    stringified
  end

  def add_intro(pdf)
    # patient_name = 'FAKE PATIENT NAME' # TODO: fix when LH client can do calls to Patient endpoint
    patient_name = stringify_patient
    #gen_stamp = '09/01/2021 at 10:23am EST' # TODO: fix when I figure out how to do Ruby time manipulation
    gen_time = Time.now
    gen_stamp = "#{gen_time.strftime("%m/%d/%Y")} at #{gen_time.strftime("%I:%M %p")}"

    intro_lines = [
      "<b><font size='8'>Hypertension Rapid Ready for Decision | Claim for Increase</font></b>\n",
      "<font size='16'>VHA Hypertension Data Summary for</font>",
      "<font size='16'>#{patient_name}</font>\n",
      "<font size='8'><i>#{gen_stamp}<i>\n"
    ]

    intro_lines.each do |line|
      pdf.text line, inline_format: true
    end

    pdf.text "\n", size: 12

    pdf
  end

  def add_blood_pressure(pdf)
    header = bp_data.length.positive? ? 'One Year of Blood Pressure History' : 'No blood pressure records found'
    bp_note = bp_data.length.positive? ? "<font size='8'>Blood pressure is shown as systolic/diastolic.\n</font>" : ''
    end_date= @date.strftime("%m/%d/%Y")
    start_date = (@date - 1.year).strftime("%m/%d/%Y")
    search_window = "VHA records searched from #{start_date} to #{end_date}"
    bp_intro_lines = [
      "<font size='14'>#{header}</font>",
      "<font size='8'><i>#{search_window}<i></font>",
      "<font size='8'><i>All VAMC locations using VistA/CAPRI were checked.<i></font>",
      bp_note
    ]

    bp_intro_lines.each do |line|
      pdf.text line, inline_format: true
    end

    if !bp_data.length.positive?
      return pdf
    end

    pdf.text "\n", size: 12
    bp_rows = [['<b>Blood pressure</b>', '<b>Date</b>', '<b>Location</b>']]
    @bp_data.each do |bp|
      bp_rows.append([
                       "#{bp[:systolic]['value']}/#{bp[:diastolic]['value']} #{bp[:systolic]['unit']}",
                       bp[:issued][0, 10].to_date.strftime("%m/%d/%Y"),
                       bp[:organization] || 'Unknown'
                     ])
    end
    pdf.table(bp_rows, cell_style: { size: 8, inline_format: true })

    pdf.text "\n", size: 12

    pdf.text 'Hypertension Rating Schedule', size: 12

    pdf.table([
                [
                  '10%',
                  'Systolic pressure predominantly 160 or more; or diastolic pressure predominantly 100 or more; or minimum evaluation for an individual with a history of diastolic pressure predominantly 100 or more who requires continuous medication for control.'
                ],
                [
                  '20%', 'Systolic pressure predominantly 200 or more; or diastolic pressure predominantly 110 or more.'
                ],
                [
                  '40%', 'Diastolic pressure 120 or more.'
                ],
                [
                  '60%', 'Diastolic pressure 130 or more.'
                ]
              ], cell_style: { size: 8 })

    pdf.text "\n"
    pdf.text "<link href='https://www.ecfr.gov/current/title-38/chapter-I/part-4'>View rating schedule</link>",
             inline_format: true, color: '0000ff', size: 7

    pdf

  end

  def add_medications(pdf)
    pdf.text "\n", size: 12
    pdf.text 'Active Prescriptions', size: 14

    med_search_window = "VHA records searched for medication prescriptions active as of #{Date.today.strftime('%m/%d/%Y')}."
    prescription_lines = [
      med_search_window,
      'All VAMC locations using VistA/CAPRI were checked',
      "\n"
    ]

    prescription_lines.each do |line|
      pdf.text line, size: 8, style: :italic
    end

    med_rows = [[
      '<b>Medication</b>',
      '<b>Prescribed on</b>',
      '<b>Dosage instructions</b>'
    ]]

    @medications.each do |medication|
      issued_date = medication['authoredOn'][0, 10].to_date.strftime("%m/%d/%Y")
      instructions = medication['dosageInstructions'].join('; ')
      med_rows.append([medication['description'], issued_date, instructions])
    end

    pdf.table(med_rows, cell_style: { size: 8, inline_format: true })

    pdf
  end

  def add_about(pdf)
    about_lines = [
      "\n",
      'About this document',
      'The Hypertension Rapid Ready for Decision system retrieves and summarizes VHA medical records related to hypertension claims for increase submitted on va.gov. VSRs and RVSRs can develop and rate this claim without ordering an exam if there is sufficient existing evidence to show predominance according to DC 7101 (Hypertension) Rating Criteria. This is not new guidance, but rather a way to operationalize existing statutory rules in 38 U.S.C § 5103a(d).',
      'Not included in this document:',
      ' -  Private medical records',
      ' -  VAMC data for clinics using CERNER Electronic Health Record system (Replacing VistA, but currently only used at Mann-Grandstaff VA Medical Center in Spokane, Washington)',
      ' -  JLV/Department of Defense medical records'
    ]

    about_lines.each do |line|
      pdf.text line, size: 6
    end

    pdf
  end
end


class HypertensionSpecialIssueManager
  attr_accessor :submission

  def initialize(submission)
    @submission = submission
  end

  def add_special_issue
    data = JSON.parse(submission.form_json)
    disabilities = data['form526']['form526']['disabilities']
    added = add_rrd_to_disabilities(disabilities)
    data['form526']['form526']['disabilities'] = disabilities
    # TODO: do we need to also add the special issue to secondary disabilities?
    # This code currently does not do that, but some disabilities have a
    # secondaryDisabilities property within the disability.
    submission.form_json = JSON.dump(data)
    submission.save
    return JSON.dump(data) # TODO: update tests so that this return value is unnecessary
  end

  def add_rrd_to_disabilities(disabilities)
    disabilities.each do |da|
      if da['diagnosticCode'] == 7101 && da['disabilityActionType'].downcase == 'increase'
        ad = add_rrd(da)
      end
    end
  end

  def add_rrd(disability)
    rrd_hash = {'code'=> 'RRD', 'name'=> 'Rapid Ready for Decision'}
    if disability['specialIssues'].blank?
      disability['specialIssues'] = [rrd_hash]
    elsif !disability['specialIssues'].include? rrd_hash
      disability['specialIssues'].append(rrd_hash)
    end
    return disability
  end
end
