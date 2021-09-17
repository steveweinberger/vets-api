module V0
    class ClaimantsController < ApplicationController
      skip_before_action :authenticate

      def eligibility
        render json: {
            "claimant": {
              "claimantId": 0,
              "firstName": "string",
              "middleName": "string",
              "lastName": "string",
              "dateOfBirth": "2021-09-17",
              "cadency": "string",
              "contactInfos": [
                {
                  "addressLine1": "string",
                  "addressLine2": "string",
                  "addressLine3": "string",
                  "city": "string",
                  "zipcode": "string",
                  "effectiveDate": "2021-09-17",
                  "zipCodeExtension": "string",
                  "emailAddress": "user@example.com",
                  "addressType": "DOMESTIC"
                }
              ],
              "personComments": [
                {
                  "personCommentKey": 0,
                  "commentDate": "2021-09-17",
                  "comments": "string"
                }
              ],
              "dobChanged": true,
              "firstAndLastNameChanged": true
            }
          }
    end

  end
end
