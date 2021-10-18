# frozen_string_literal: true

require 'json_marshal/marshaller'
# require 'common/exceptions'

module AppealsApi
  class SupplementalClaim < ApplicationRecord
    def self.past?(date)
      date < Time.zone.today
    end

    def self.date_from_string(string)
      string.match(/\d{4}-\d{2}-\d{2}/) && Date.parse(string)
    rescue ArgumentError
      nil
    end

    STATUSES = %w[pending success error].freeze

    serialize :auth_headers, JsonMarshal::Marshaller
    serialize :form_data, JsonMarshal::Marshaller
    encrypts :auth_headers, :form_data, **lockbox_options

    has_many :evidence_submissions, as: :supportable, dependent: :destroy
    has_many :status_updates, as: :statusable, dependent: :destroy
    # the controller applies the JSON Schemas in modules/appeals_api/config/schemas/
    # further validations:
    validate(
      :birth_date_is_a_date,
      :birth_date_is_in_the_past,
      :contestable_issue_dates_are_valid_dates,
      if: proc { |a| a.form_data.present? }
    )

    def pdf_structure(version)
      Object.const_get(
        "AppealsApi::PdfConstruction::SupplementalClaim::#{version.upcase}::Structure"
      ).new(self)
    end

    def veteran_first_name
      auth_headers.dig('X-VA-First-Name')
    end

    def veteran_middle_initial
      auth_headers.dig('X-VA-Middle-Initial')
    end

    def veteran_last_name
      auth_headers.dig('X-VA-Last-Name')
    end

    def full_name
      "#{veteran_first_name} #{veteran_middle_initial} #{veteran_last_name}".squeeze(' ').strip
    end

    def ssn
      auth_headers.dig('X-VA-SSN')
    end

    def file_number
      auth_headers.dig('X-VA-File-Number')
    end

    def veteran_dob_month
      birth_date.strftime '%m'
    end

    def veteran_dob_day
      birth_date.strftime '%d'
    end

    def veteran_dob_year
      birth_date.strftime '%Y'
    end

    def veteran_service_number
      auth_headers.dig('X-VA-Service-Number')
    end

    def insurance_policy_number
      auth_headers.dig('X-VA-Insurance-Policy-Number')
    end

    def mailing_address_number_and_street
      address_combined
    end

    def mailing_address_city
      veteran.dig('address', 'city') || ''
    end

    def mailing_address_state
      veteran.dig('address', 'stateCode') || ''
    end

    def mailing_address_country
      veteran.dig('address', 'countryCodeISO2') || ''
    end

    def zip_code
      if zip_code_5 == '00000'
        veteran.dig('address', 'internationalPostalCode') || '00000'
      else
        zip_code_5
      end
    end

    def zip_code_5
      veteran.dig('address', 'zipCode5') || '00000'
    end

    def phone
      veteran_phone.to_s
    end

    def veteran_phone_data
      veteran&.dig('phone')
    end

    def email
      veteran&.dig('email')&.strip
    end

    def consumer_name
      auth_headers&.dig('X-Consumer-Username')
    end

    def consumer_id
      auth_headers&.dig('X-Consumer-ID')
    end

    def benefit_type
      data_attributes&.dig('benefitType')&.strip
    end

    def contestable_issues
      issues = form_data.dig('included') || []

      @contestable_issues ||= issues.map do |issue|
        AppealsApi::ContestableIssue.new(issue)
      end
    end

    def evidence_submission_days_window
      10
    end

    def accepts_evidence?
      true
    end

    def soc_opt_in
      data_attributes&.dig('socOptIn')
    end

    def new_evidence_locations
      evidence_submissions = evidence_submission['retrieveFrom'] || []

      @evidence_locations ||= evidence_submissions.map do |retrieve_from|
        retrieve_from['attributes']['locationAndName']
      end
    end

    def new_evidence_dates
      evidence_submissions = evidence_submission['retrieveFrom'] || []

      @new_evidence_dates ||= evidence_submissions.map do |retrieve_from|
        retrieve_from['attributes']['evidenceDates']
      end
    end

    def date_signed
      veterans_local_time.strftime('%m/%d/%Y')
    end

    def lob
      {
        'compensation' => 'CMP',
        'pensionSurvivorsBenefits' => 'PMC',
        'fiduciary' => 'FID',
        'lifeInsurance' => 'INS',
        'veteransHealthAdministration' => 'OTH',
        'veteranReadinessAndEmployment' => 'VRE',
        'loanGuaranty' => 'OTH',
        'education' => 'EDU',
        'nationalCemeteryAdministration' => 'OTH'
      }[benefit_type]
    end

    private

    def data_attributes
      form_data&.dig('data', 'attributes')
    end

    def veteran
      data_attributes&.dig('veteran')
    end

    def evidence_submission
      form_data&.dig('data', 'attributes', 'evidenceSubmission')
    end

    def birth_date_string
      auth_headers&.dig('X-VA-Birth-Date')
    end

    def birth_date
      self.class.date_from_string birth_date_string
    end

    def veteran_phone
      AppealsApi::HigherLevelReview::Phone.new veteran&.dig('phone')
    end

    def veterans_local_time
      veterans_timezone ? created_at.in_time_zone(veterans_timezone) : created_at.utc
    end

    def veterans_timezone
      veteran&.dig('timezone').presence&.strip
    end

    # validation (header)
    def birth_date_is_a_date
      add_error("Veteran birth date isn't a date: #{birth_date_string.inspect}") unless birth_date
    end

    # validation (header)
    def birth_date_is_in_the_past
      return unless birth_date

      add_error("Veteran birth date isn't in the past: #{birth_date}") unless self.class.past? birth_date
    end

    def contestable_issue_dates_are_valid_dates
      return if contestable_issues.blank?

      contestable_issues.each_with_index do |issue, index|
        decision_date_invalid(issue, index)
        decision_date_not_in_past(issue, index)
      end
    end

    def decision_date_invalid(issue, issue_index)
      return if issue.decision_date

      add_decision_date_error "isn't a valid date: #{issue.decision_date_string.inspect}", issue_index
    end

    def decision_date_not_in_past(issue, issue_index)
      return if issue.decision_date.nil? || issue.decision_date_past?

      add_decision_date_error "isn't in the past: #{issue.decision_date_string.inspect}", issue_index
    end

    def add_decision_date_error(string, issue_index)
      add_error "included[#{issue_index}].attributes.decisionDate #{string}"
    end

    def add_error(message)
      errors.add(:base, message)
    end

    def address_combined
      return unless veteran.dig('address', 'addressLine1')

      @address_combined ||=
        [veteran.dig('address', 'addressLine1'),
         veteran.dig('address', 'addressLine2'),
         veteran.dig('address', 'addressLine3')].compact.map(&:strip).join(' ')
    end
  end
end
