# frozen_string_literal: true

module MebApi
  module V0
    class EducationBenefitsController < MebApi::V0::BaseController
      def claimant_info
        render json:
          {
            data:
              {
                'claimant':
                  { 'claimantId': '1000000000000246', 'suffix': '', 'dateOfBirth': '1970-01-01', 'firstName': 'Herbert',
                    'lastName': 'Hoover', 'middleName': '',
                    'contactInfo':
                        { 'addressLine1': '123 Martin Luther King Blvd', 'addressLine2': '', 'city': 'New Orleans',
                          'zipcode': '70115', 'effectiveDate': '', 'zipCodeExtension': '',
                          'emailAddress': 'test@test.com',
                          'addressType': 'MILITARY_OVERSEAS', 'mobilePhoneNumber': '512-825-5445',
                          'homePhoneNumber': '222-333-3333', 'countryCode': 'US', 'stateCode': 'ME' },
                    'dobChanged': false,
                    'firstAndLastNameChanged': false,
                    'contactInfoChanged': false,
                    'notificationMethod': 'email',
                    'preferredContact': 'mail' }
              }
          }
      end

      def service_history
        render json:
        { data: {
          'beginDate': '2021-09-23',
          'endDate': '2021-09-23',
          'branchOfService': 'ArmyActiveDuty',
          'trainingPeriods': [
            {
              'beginDate': '2021-09-23',
              'endDate': '2021-09-23'
            }
          ],
          'exclusionPeriods': [{ 'beginDate': '2021-09-23', 'endDate': '2021-09-23' }],
          'characterOfService': 'string',
          'separationReason': 'string',
          'serviceStatus': 'Veteran',
          'disagreeWithServicePeriod': true
        } }
      end

      def eligibility
        render json:
        { data: {
          'veteranIsEligible': true,
          'chapter': 'chapter33'
        } }
      end

      def claim_status
        render json:
        { data: {
          'claimId': 0,
          'status': 'InProgress'
        } }
      end
    end
  end
end
