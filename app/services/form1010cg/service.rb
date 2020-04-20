# frozen_string_literal: true

# This service manages the interactions between CaregiversAssistanceClaim, CARMA, and Form1010cg::Submission.
module Form1010cg
  class Service
    def submit_claim!(claim)
      claim.valid? || raise(Common::Exceptions::ValidationErrors, claim)

      carma_submission = CARMA::Models::Submission.from_claim(claim)
      carma_submission.metadata = fetch_and_build_metadata(claim)
      carma_submission.submit!

      Form1010cg::Submission.new(
        carma_case_id: carma_submission.carma_case_id,
        submitted_at: carma_submission.submitted_at
      )
    end

    private

    # Destroy this form it has previously been stored in-progress by this user_context
    def form_schema_id
      SavedClaim::CaregiversAssistanceClaim::FORM
    end

    def fetch_and_build_metadata(claim)
      form_data = claim.parsed_form
      metadata = {}

      # Add find the ICN for each person on the form
      mvi_searches.each do |mvi_search|
        data_namespace = mvi_search[:data_namespace]
        metadata_namespace = mvi_search[:metadata_namespace]
        next if form_data[data_namespace].nil? && mvi_search[:optional?]

        attributes = build_mvi_profile_search(form_data, data_namespace)
        response = mvi.find_profile_by_attributes(attributes)

        metadata[metadata_namespace.to_sym] = { icn: response&.profile&.icn } if response.status == 'OK'

        # If person cannot be found in MVI, raise a Common::Exceptions::ValidationErrors

        # TODO: [:icn].nil? is the wrong check. The object won't be there at all...
        if mvi_search[:assertIcnPresence?] && metadata[metadata_namespace.to_sym][:icn].nil?
          claim.errors.add(
            :base,
            "#{data_namespace.camelize}NotFound".snakecase.to_sym,
            message: "#{data_namespace.titleize} could not be found in the VA's system"
          )

          # TODO: This claim is saved at this point... so should we really make a error on claim?
          # Maybe we shouldn't save the claim till after metadata is built...

          raise(Common::Exceptions::ValidationErrors, claim)
        end
      end

      metadata
    end

    def mvi_searches
      [
        { data_namespace: 'veteran', metadata_namespace: 'veteran', optional?: false, assertIcnPresence?: true },
        { data_namespace: 'primaryCaregiver', metadata_namespace: 'primaryCaregiver', optional?: false },
        { data_namespace: 'secondaryOneCaregiver', metadata_namespace: 'secondaryCaregiverOne', optional?: true },
        { data_namespace: 'secondaryTwoCaregiver', metadata_namespace: 'secondaryCaregiverTwo', optional?: true }
      ]
    end

    def build_mvi_profile_search(parsed_form_data, namespace)
      data = parsed_form_data[namespace]

      OpenStruct.new(
        first_name: data['fullName']['first'],
        middle_name: data['fullName']['middle'],
        last_name: data['fullName']['last'],
        birth_date: data['dateOfBirth'],
        gender: data['gender'],
        ssn: data['ssnOrTin']
      )
    end

    def mvi
      @mvi ||= MVI::Service.new
    end
  end
end
