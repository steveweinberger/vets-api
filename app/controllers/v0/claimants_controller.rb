# frozen_string_literal: true

module V0
  class ClaimantsController < ApplicationController
    skip_before_action :authenticate

    def eligibility
      render json:
      {
        "claimant": {
          "claimantId": 0,
          "firstName": 'string',
          "middleName": 'string',
          "lastName": 'string',
          "dateOfBirth": '2021-09-17',
          "contactInfos": [
            {
              "addressLine1": 'string',
              "addressLine2": 'string',
              "city": 'string',
              "zipcode": 'string',
              "effectiveDate": '2021-09-17',
              "emailAddress": 'vets.gov.user+1@gmail.com'
            }
          ]
        }
      }
    end
  end
end
