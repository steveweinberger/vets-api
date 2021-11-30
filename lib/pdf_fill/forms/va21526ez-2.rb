# frozen_string_literal: true

require 'pdf_fill/hash_converter'
require 'pdf_fill/forms/form_base'
require 'string_helpers'

module PdfFill
  module Forms
    # rubocop:disable Metrics/ClassLength
    class Va21526ez < FormBase
      include FormHelper
      ITERATOR = PdfFill::HashConverter::ITERATOR

      # rubocop:disable Layout/LineLength
      KEY = {
        'standardClaim': {
          'checkbox': {
            key: 'F[0].Page_9[0].Standard_Claim_Process[0]',
            question_num: 1
          }
        },
        "fullName": {
          "first": {
            key: 'F[0].Page_9[0].Veteran_Service_Member_First_Name[0]',
            limit: 25,
            question_num: 2
          },
          "middle": {
            key: 'F[0].Page_9[0].Veteran_Service_Member_Middle_Initial[0]',
            limit: '',
            question_num: 2
          },
          "last": {
            key: 'F[0].Page_9[0].Veteran_Service_Member_Last_Name[0]',
            limit: 18,
            question_num: 2
          },
          "suffix": {
            key: 'F[0].Page_9[0].Veteran_Service_Member_Last_Name[0]',
            limit: 18,
            question_num: 2
          }
        },
        "phone": {
          'first': {
            key: 'F[0].Page_9[0].Daytime_Phone_Number_Area_Code[0]',
            limit: 3,
            question_num: 10,
            question_text: 'TELEPHONE NUMBER(S) (Optional) (Include Area Code). Daytime. Enter Area Code.'
          },
          'second': {
            key: 'F[0].Page_9[0].Daytime_Phone_Middle_Three_Numbers[0]',
            limit: 3,
            question_num: 10,
            question_text: 'TELEPHONE NUMBER(S). Daytime. Enter middle three numbers.'
          },
          'third': {
            key: 'F[0].Page_9[0].Daytime_Phone_Last_Four_Numbers[0]',
            limit: 4,
            question_num: 10,
            question_text: 'TELEPHONE NUMBER(S). Daytime. Enter last four numbers.'
          }
        },
        "date": {
        },
        "email": {
          key: 'F[0].Page_9[0].Email_Address_Optional[0]',
          limit: 25,
          question_num: 12
        },
        'isVaEmployee': {
          'checkbox': {
            key: 'F[0].Page_9[0].Current_VA_Employee_Check_Box[0]',
            question_num: 13
          }
        },
        "specialIssues": {
        },
        "country": {
        },
        "state": {
        },
        "address": {
          "country": {
          },
          "addressLine1": {
          },
          "addressLine2": {
          },
          "addressLine3": {
          },
          "city": {
          },
          "state": {
          },
          "zipCode": {
          }
        },
        "addressNoRequiredFields": {
          "country": {
          },
          "addressLine1": {
          },
          "addressLine2": {
          },
          "addressLine3": {
          },
          "city": {
          },
          "state": {
          },
          "zipCode": {
          }
        },
        "vaTreatmentCenterAddress": {
          "country": {
          },
          "city": {
          },
          "state": {
          }
        },
        "dateRange": {
          "from": {
          },
          "to": {
          }
        },
        "dateRangeAllRequired": {
          "from": {
          },
          "to": {
          }
        },
        "ratedDisabilities": {
          "name": {
          },
          "disabilityActionType": {
          },
          "specialIssues": {
          },
          "ratedDisabilityId": {
          },
          "diagnosticCode": {
          },
          "classificationCode": {
          },
          "secondaryDisabilities": {
            "name": {
            },
            "disabilityActionType": {
            },
            "specialIssues": {
            },
            "ratedDisabilityId": {
            },
            "diagnosticCode": {
            },
            "classificationCode": {
            }
          }
        },
        "newDisabilities": {
          "condition": {
          },
          "cause": {
          },
          "classificationCode": {
          },
          "primaryDescription": {
          },
          "causedByDisability": {
          },
          "causedByDisabilityDescription": {
          },
          "specialIssues": {
          },
          "worsenedDescription": {
          },
          "worsenedEffects": {
          },
          "vaMistreatmentDescription": {
          },
          "vaMistreatmentLocation": {
          },
          "vaMistreatmentDate": {
          }
        },
        "unitAssigned": {
        },
        "unitAssignedDates": {
          "from": {
          },
          "to": {
          }
        },
        "ptsdIncident": {
          "incidentDate": {
          },
          "incidentDescription": {
          },
          "unitAssigned": {
          },
          "unitAssignedDates": {
          }
        },
        "secondaryPtsdIncident": {
          "sources": {
            "name": {
            },
            "incidentDate": {
            },
            "description": {
            },
            "unitAssigned": {
            },
            "unitAssignedDates": {
            }
          }
        },
        "first": {
        },
        "middle": {
        },
        "last": {
        },
        "serviceInformation": {
          "servicePeriods": {
            "serviceBranch": {
            },
            "dateRange": {
            }
          },
          "separationLocation": {
            "separationLocationCode": {
            },
            "separationLocationName": {
            }
          },
          "reservesNationalGuardService": {
            "unitName": {
            },
            "obligationTermOfServiceDateRange": {
            },
            "receivingTrainingPay": {
            },
            "title10Activation": {
              "title10ActivationDate": {
              },
              "anticipatedSeparationDate": {
              }
            }
          }
        },
        "confinements": {
        },
        "militaryRetiredPayBranch": {
        },
        "waiveRetirementPay": {
        },
        "hasSeparationPay": {
        },
        "separationPayDate": {
        },
        "separationPayBranch": {
        },
        "hasTrainingPay": {
        },
        "waiveTrainingPay": {
        },
        "newPrimaryDisabilities": {
        },
        "newSecondaryDisabilities": {
        },
        "mailingAddress": {
        },
        "forwardingAddress": {
          "country": {
          },
          "addressLine1": {
          },
          "addressLine2": {
          },
          "addressLine3": {
          },
          "city": {
          },
          "state": {
          },
          "zipCode": {
          },
          "effectiveDate": {
          }
        },
        "phoneAndEmail": {
          "primaryPhone": {
          },
          "emailAddress": {
          }
        },
        "homelessOrAtRisk": {
        },
        "homelessHousingSituation": {
        },
        "otherHomelessHousing": {
        },
        "needToLeaveHousing": {
        },
        "atRiskHousingSituation": {
        },
        "otherAtRiskHousing": {
        },
        "homelessnessContact": {
          "name": {
          },
          "phoneNumber": {
          }
        },
        "isTerminallyIll": {
        },
        "vaTreatmentFacilities": {
          "treatmentCenterName": {
          },
          "treatmentDateRange": {
          },
          "treatmentCenterAddress": {
          },
          "treatedDisabilityNames": {
          }
        },
        "attachments": {
          "name": {
          },
          "confirmationCode": {
          },
          "attachmentId": {
          }
        },
        "bankAccountType": {
        },
        "bankAccountNumber": {
        },
        "bankRoutingNumber": {
        },
        "bankName": {
        },
        "mentalChanges": {
          "depression": {
          },
          "obsessive": {
          },
          "prescription": {
          },
          "substance": {
          },
          "hypervigilance": {
          },
          "agoraphobia": {
          },
          "fear": {
          },
          "other": {
          },
          "otherExplanation": {
          },
          "noneApply": {
          }
        },
        "privateMedicalRecordAttachments": {
          "name": {
          },
          "confirmationCode": {
          },
          "attachmentId": {
          }
        },
        "completedFormAttachments": {
          "name": {
          },
          "confirmationCode": {
          },
          "attachmentId": {
          }
        },
        "secondaryAttachment": {
          "name": {
          },
          "confirmationCode": {
          },
          "attachmentId": {
          }
        },
        "unemployabilityAttachments": {
          "name": {
          },
          "confirmationCode": {
          },
          "attachmentId": {
          }
        },
        "employmentRequestAttachments": {
          "name": {
          },
          "confirmationCode": {
          },
          "attachmentId": {
          }
        }
      }.freeze
      # rubocop:enable Layout/LineLength

      def merge_fields
        @form_data['fullName']['last'] = extract_lastname_and_suffix.first
        @form_data['fullName']['suffix'] = extract_lastname_and_suffix.last

        @form_data
      end

      private

      def extract_lastname_and_suffix
        last, suffix = @form_data['fullName']['last'].split(' ')
        suffix ||= ''

        [last, suffix]
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
