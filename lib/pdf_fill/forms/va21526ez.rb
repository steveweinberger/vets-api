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
        'veteran': {
          'flashes': {
          },
          'standardClaim': {
            'checkbox': {
              key: 'F[0].Page_9[0].Standard_Claim_Process[0]',
              question_num: 1,
              question_text: 'Check box. Standard Claim Process.'
            }
          },
          'currentMailingAddress': {
            'addressLine1': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_NumberAndStreet[0]',
              limit: 30,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter Number and Street.'
            },
            'addressLine2': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_ApartmentOrUnitNumber[0]',
              limit: 5,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter Appartment or Unit Number.'
            },
            'city': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_City[0]',
              limit: 18,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter City.'
            },
            'state': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_StateOrProvince[0]',
              limit: 2,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter State or Province.'
            },
            'country': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_Country[0]',
              limit: 2,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter Country.'
            },
            'zipFirstFive': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_ZIPOrPostalCode_FirstFiveNumbers[0]',
              limit: 5,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter ZIP or Postal Code. First 5 digits.'
            },
            'zipLastFour': {
              key: 'F[0].Page_9[0].CurrentMailingAddress_ZIPOrPostalCode_LastFourNumbers[0]',
              limit: 4,
              question_num: 11,
              question_text: 'Current Mailing Address. Enter ZIP or Postal Code. Enter last 4 digits.'
            }
          },
          'currentlyVAEmployee': {
            'checkbox': {
              key: 'F[0].Page_9[0].Current_VA_Employee_Check_Box[0]',
              question_num: 13
            }
          },
          'changeOfAddress': {
            'addressChangeType': {
              question_num: 14,
              question_suffix: 'A',
              question_text: 'TYPE OF ADDRESS CHANGE (Complete if applicable) (Check only one box)',
              'checkbox': {
                'temporary': {
                  key: 'F[0].Page_9[0].Temporary[0]'
                },
                'permanent': {
                  key: 'F[0].Page_9[0].Permanent[0]'
                }
              }
            },
            'addressLine1': {
              key: 'F[0].Page_9[0].New_Address_NumberAndStreet[0]',
              limit: 30,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter Number and Street.'
            },
            'addressLine2': {
              key: 'F[0].Page_9[0].New_Address_ApartmentOrUnitNumber[0]',
              limit: 5,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter Apartment or Unit Number.'
            },
            'city': {
              key: 'F[0].Page_9[0].New_Address_City[0]',
              limit: 18,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter City.'
            },
            'state': {
              key: 'F[0].Page_9[0].New_Address_StateOrProvince[0]',
              limit: 2,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter State or Province.'
            },
            'country': {
              key: 'F[0].Page_9[0].New_Address_Country[0]',
              limit: 2,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter Country.'
            },
            'zipFirstFive': {
              key: 'F[0].Page_9[0].New_Address_ZIPOrPostalCode_FirstFiveNumbers[0]',
              limit: 5,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter ZIP or Postal Code. First 5 digits.'
            },
            'zipLastFour': {
              key: 'F[0].Page_9[0].New_Address_ZIPOrPostalCode_LastFourNumbers[0]',
              limit: 4,
              question_num: 14,
              question_suffix: 'B',
              question_text: 'New Address. Enter ZIP or Postal Code. Enter last 4 digits.'
            },
            'beginningDate': {
              'month': {
                key: 'F[0].Page_9[0].Beginning_Date_Month[0]',
                limit: 2,
                question_num: 14,
                question_suffix: 'C',
                question_text: 'Beginning Date. Enter 2 digit Month.'
              },
              'day': {
                key: 'F[0].Page_9[0].Beginning_Date_Day[0]',
                limit: 2,
                question_num: 14,
                question_suffix: 'C',
                question_text: 'Beginning Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].Page_9[0].Beginning_Date_Year[0]',
                limit: 2,
                question_num: 14,
                question_suffix: 'C',
                question_text: 'Beginning Date. Enter 4 digit bear.'
              }
            },
            'endingDate': {
              'month': {
                key: 'F[0].Page_9[0].Ending_Date_Month[0]',
                limit: 2,
                question_num: 14,
                question_suffix: 'C',
                question_text: 'Ending Date. Enter 2 digit Month.'
              },
              'day': {
                key: 'F[0].Page_9[0].Ending_Date_Day[0]',
                limit: 2,
                question_num: 14,
                question_suffix: 'C',
                question_text: 'Ending Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].Page_9[0].Ending_Date_Year[0]',
                limit: 2,
                question_num: 14,
                question_suffix: 'C',
                question_text: 'Ending Date. Enter 4 digit bear.'
              }
            }
          },
          'homelessness': {
            'currentlyHomeless': {
              'yes' => {
                key: 'F[0].Page_10[0].YES[0]',
                question_num: 15,
                question_suffix: 'A',
                question_text: 'ARE YOU CURRENTLY HOMELESS? Check box. YES. (If "Yes," complete Item 15. B. regarding your living situation).'
              },
              'no' => {
                key: 'F[0].Page_10[0].NO[0]',
                question_num: 15,
                question_suffix: 'A'
              },
              'homelessSituationType': {
                'shelter': {
                  key: 'F[0].Page_10[0].Living_In_A_Homeless_Shelter[0]',
                  question_num: 15,
                  question_suffix: 'B',
                  question_text: 'CHECK THE BOX THAT APPLIES TO YOUR LIVING SITUATION. Check box. Living in a homeless shelter.'
                },
                'notShelter': {
                  key: 'F[0].Page_10[0].Not_Currently_In_A_Sheltered_Environment_e\.g\._Living_In_A_Car_Or_Tent[0]',
                  question_num: 15,
                  question_suffix: 'B',
                  question_text: 'Check box. Not currently in a sheltered environment (e.g., living in a car or tent).'
                },
                'anotherPerson': {
                  key: 'F[0].Page_10[0].Staying_With_Another_Person[0]',
                  question_num: 15,
                  question_suffix: 'B',
                  question_text: 'Check box. Staying with another person.'
                },
                'fleeing': {
                  key: 'F[0].Page_10[0].Fleeing_Current_Residence[0]',
                  question_num: 15,
                  question_suffix: 'B',
                  question_text: 'Check box. Fleeing current residence.'
                },
                'other': {
                  key: 'F[0].Page_10[0].OTHER_Specify[0]',
                  question_num: 15,
                  question_suffix: 'B',
                  question_text: 'Check box. Other (Specify).'
                }
              },
              'otherLivingSituation': {
                key: 'F[0].Page_10[0].SPECIFY_OTHER_LIVING_SITUATION[0]',
                limit: 10,
                question_num: 15,
                question_suffix: 'B',
                question_text: 'SPECIFY OTHER LIVING SITUATION.'
              }
            },
            'homelessnessRisk': {
              'yes': {
                key: 'F[0].Page_10[0].YES[1]',
                question_num: 15,
                question_suffix: 'C',
                question_text: 'ARE YOU CURRENTLY AT RISK OF BECOMING HOMELESS? Check box. YES. (If "Yes," complete Item 15. D. regarding your living situation).'
              },
              'no': {
                key: 'F[0].Page_10[0].NO[1]',
                question_num: 15,
                question_suffix: 'C',
                question_text: 'Check box. NO.'
              },
              'homelessnessRiskSituationType': {
                'losingHousing': {
                  key: 'F[0].Page_10[0].Housing_Will_Be_Lost_In_30_Days[0]',
                  question_num: 15,
                  question_suffix: 'D',
                  question_text: 'Check box. Housing will be lost in 30 days.'
                },
                'leavingShelter': {
                  key: 'F[0].Page_10[0].Leaving_Publicly_Funded_System_Of_Care_e\.g\._Homeless_Shelter[0]',
                  question_num: 15,
                  question_suffix: 'D',
                  question_text: 'Check box. Leaving publicly funded system of care. (e.g., homeless shelter).'
                },
                'other': {
                  key: 'F[0].Page_10[0].OTHER_Specify[1]',
                  limit: 10,
                  question_num: 15,
                  question_suffix: 'D',
                  question_text: 'Check box. Other (Specify).'
                }
              },
              'otherLivingSituation': {
                key: 'F[0].Page_10[0].SPECIFY_OTHER_LIVING_SITUATION[1]',
                limit: 10,
                question_num: 15,
                question_suffix: 'D',
                question_text: 'SPECIFY OTHER LIVING SITUATION.'
              }
            },
            'pointOfContact': {
              'pointOfContactName': {
                key: 'F[0].Page_10[0].Point_Of_Contact_Name_Of_Person_VA_Can_Contact_In_Order_To_Get_In_Touch_With_You[0]',
                limit: 20,
                question_num: 15,
                question_suffix: 'E',
                question_text: 'POINT OF CONTACT (Name of person V. A. can contact in order to get in touch with you).'
              },
              'primaryPhone': {
                key: 'F[0].Page_10[0].PointOfContactTelephoneNumber_Include_Area_Code[0]',
                limit: 10,
                question_num: 15,
                question_suffix: 'F',
                question_text: 'POINT OF CONTACT TELEPHONE NUMBER (Include Area Code).'
              }
            }
          },
          'isTerminallyIll': {
          }
        },
        'serviceInformation': {
          'servicePeriods': {
            'serviceBranch': {
              'army': {
                key: 'F[0].#subform[10].Army[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Branch of Service. Check box. Army.'
              },
              'navy': {
                key: 'F[0].#subform[10].Navy[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Branch of Service. Check box. Navy.'
              },
              'marine_corps': {
                key: 'F[0].#subform[10].Marine_Corps[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Marine Corps.'
              },
              'air_force': {
                key: 'F[0].#subform[10].Air_Force[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Air Force.'
              },
              'coast_guard': {
                key: 'F[0].#subform[10].Coast_Guard[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Coast Guard.'
              },
              'space_force': {
                key: 'F[0].#subform[10].Space_Force[1]',
                question_num: 24,
                question_suffix: 'C',
                question_text: 'Check box. Space Force.'
              }
            },
            'activeDutyBeginDate': {
              'month': {
                key: 'F[0].#subform[9].EntryDate_Month[0]',
                question_num: 20,
                question_suffix: 'A',
                question_text: 'Most recent active service entry date(s). Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].EntryDate_Day[0]',
                question_num: 20,
                question_suffix: 'A',
                question_text: 'Most recent active service entry date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].EntryDate_Year[0]',
                question_num: 20,
                question_suffix: 'A',
                question_text: 'Most recent active service entry date. Enter 4 digit Year.'
              }
            },
            'activeDutyEndDate': {
              'month': {
                key: 'F[0].#subform[9].ExitDate_Month[0]',
                question_num: 20,
                question_suffix: 'A',
                question_text: 'Most recent active service exit date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].ExitDate_Day[0]',
                question_num: 20,
                question_suffix: 'A',
                question_text: 'Most recent active service exit date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].ExitDate_Year[0]',
                question_num: 20,
                question_suffix: 'A',
                question_text: 'Most recent active service exit date. Enter 4 digit Year.'
              }
            },
            'separationLocationCode': {
            }
          },
          'confinements': {
            'confinementBeginDate': {
              'first': {
                'month': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Month[0]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. From Date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Day[0]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. From Date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Year[0]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. From Date. Enter 4 digit Year.'
                }
              },
              'second': {
                'month': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Month[2]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. From Date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Day[2]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. From Date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Year[2]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. From Date. Enter 4 digit Year.'
                }
              }
            },
            'confinementEndDate': {
              'first': {
                'month': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Month[1]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. To Date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Day[1]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. To Date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Year[1]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. To Date. Enter 4 digit Year.'
                }
              },
              'second': {
                'month': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Month[3]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. To Date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Day[3]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. To Date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].DatesOfConfinement_Year[3]',
                  question_num: 23,
                  question_suffix: 'B',
                  question_text: 'Dates of confinement. To Date. Enter 4 digit Year.'
                }
              }
            }
          },
          'reservesNationalGuardService': {
            'title10Activation': {
              'title10ActivationDate': {
                'month': {
                  key: 'F[0].#subform[9].DateOfActivation_Month[0]',
                  question_num: 22,
                  question_suffix: 'B',
                  question_text: 'Date of Activation. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].DateOfActivation_Day[0]',
                  question_num: 22,
                  question_suffix: 'B',
                  question_text: 'Date of Activation. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].DateOfActivation_Year[0]',
                  question_num: 22,
                  question_suffix: 'B',
                  question_text: 'Date of Activation. Enter 4 digit Year.'
                }
              },
              'anticipatedSeparationDate': {
                'month': {
                  key: 'F[0].#subform[9].AnticipatedSeparationDate_Month[0]',
                  question_num: 22,
                  question_suffix: 'C',
                  question_text: 'Anticipated separation date. Enter 2 digit month.'
                },
                'day': {
                  key: 'F[0].#subform[9].AnticipatedSeparationDate_Day[0]',
                  question_num: 22,
                  question_suffix: 'C',
                  question_text: 'Anticipated separation date. Enter 2 digit day.'
                },
                'year': {
                  key: 'F[0].#subform[9].AnticipatedSeparationDate_Year[0]',
                  question_num: 22,
                  question_suffix: 'C',
                  question_text: 'Anticipated separation date. Enter 4 digit Year.'
                }
              }
            },
            'obligationTermOfServiceFromDate': {
              'month': {
                key: 'F[0].#subform[9].ObligationTermOfService_Month[0]',
                question_num: 21,
                question_suffix: 'C',
                question_text: 'Obligation Term of Service. From Date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].ObligationTermOfService_Day[0]',
                question_num: 21,
                question_suffix: 'C',
                question_text: 'From Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].ObligationTermOfService_Year[0]',
                question_num: 21,
                question_suffix: 'C',
                question_text: 'From Date. Enter 4 digit Year.'
              }
            },
            'obligationTermOfServiceToDate': {
              'month': {
                key: 'F[0].#subform[9].ObligationTermOfService_Month[1]',
                question_num: 21,
                question_suffix: 'C',
                question_text: 'Obligation Term of Service. To Date. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[9].ObligationTermOfService_Day[1]',
                question_num: 21,
                question_suffix: 'C',
                question_text: 'To Date. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[9].ObligationTermOfService_Year[1]',
                question_num: 21,
                question_suffix: 'C',
                question_text: 'To Date. Enter 4 digit Year.'
              }
            },
            'unitName': {
              'line1': {
                key: 'F[0].#subform[9].CurrentOrLastAssignedNameAndAddressOfUnit[0]',
                linit: 15,
                question_num: 21,
                question_suffix: 'D',
                question_text: 'Current or last assigned name and address of unit. Line 1 of 2.'
              },
              'line2': {
                key: 'F[0].#subform[9].CurrentOrLastAssignedNameAndAddressOfUnit[1]',
                linit: 15,
                question_num: 21,
                question_suffix: 'D',
                question_text: 'Current or last assigned name and address of unit. Line 2 of 2.'
              }
            },
            'unitPhone': {
              key: 'F[0].#subform[9].CurrentOrAssignedPhoneNumberOfUnit[0]',
              linit: 10,
              question_num: 21,
              question_suffix: 'E',
              question_text: 'CURRENT OR ASSIGNED PHONE NUMBER OF UNIT (Include Area Code).',
              'areaCode': {
                key: ''
              },
              'phoneNumber': {
                key: ''
              }
            },
            'receivingInactiveDutyTrainingPay': {
              'checkbox': {
                key: 'F[0].#subform[10].Do_NOT_Pay_Me_VA_Compensation_I_Do_Not_Want_To_Receive_VA_Compensation_In_Lieu_Of_Training_Pay[0]'
              }
            }
          },
          'alternateNames': {
            'checkbox': {
              'yes': {
                key: 'F[0].#subform[9].CheckBox_Yes[0]',
                quiestion_num: 18,
                question_suffix: 'A',
                question_text: 'DID YOU SERVE UNDER ANOTHER NAME? Check box. YES. If "Yes," complete Item 18. B.'
              },
              'no': {
                key: 'F[0].#subform[9].CheckBox_No[0]',
                quiestion_num: 18,
                question_suffix: 'A',
                question_text: 'Check box. NO. If "No," skip to Item 19. A.'
              }
            },
            'firstName': {
              key: 'F[0].#subform[9].List_Other_Name_You_Served_Under[0]',
              quiestion_num: 18,
              question_suffix: 'B',
              question_text: 'LIST THE OTHER NAME(S) YOU SERVED UNDER.'
            },
            'middleName': {
              key: 'F[0].#subform[9].List_Other_Name_You_Served_Under[0]',
              quiestion_num: 18,
              question_suffix: 'B',
              question_text: 'LIST THE OTHER NAME(S) YOU SERVED UNDER.'
            },
            'lastName': {
              key: 'F[0].#subform[9].List_Other_Name_You_Served_Under[0]',
              quiestion_num: 18,
              question_suffix: 'B',
              question_text: 'LIST THE OTHER NAME(S) YOU SERVED UNDER.'
            }
          }
        },
        'disabilities': {
          key: 'FieldName: F[0].Page_10[0].CURRENTDISABILITY[0]',
          question_text: 'FieldNameAlt: SECTION 4: CLAIM INFORMATION. 16. CURRENT DISABILITY(IES). Line 1 of 15.',
          'specialIssues': {
          },
          'ratedDisabilityId': {
          },
          'diagnosticCode': {
          },
          'disabilityActionType': {
            'line1': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[0]',
              question_num: 16,
              question_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 0 of 15.'
            },
            'line2': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[1]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 1 of 15.'
            },
            'line3': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[2]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 2 of 15.'
            },
            'line4': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[3]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 3 of 15.'
            },
            'line5': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[4]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 4 of 15.'
            },
            'line6': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[5]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 6 of 15.'
            },
            'line7': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[6]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 7 of 15.'
            },
            'line8': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[7]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 8 of 15.'
            },
            'line9': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[8]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 9 of 15.'
            },
            'line10': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[9]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 10 of 15.'
            },
            'line11': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[10]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 11 of 15.'
            },
            'line12': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[11]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 12 of 15.'
            },
            'line13': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[12]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 13 of 15.'
            },
            'line14': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[13]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 14 of 15.'
            },
            'line15': {
              key: 'F[0].Page_10[0].Specify_Type_Of_Exposure_Event_Or_Injury[14]',
              question_num: 16,
              queston_text: 'SPECIFY TYPE OF EXPOSURE, EVENT OR INJURY. Line 15 of 15.'
            }
          },
          'name': {
            'line1': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[0]',
              question_num: 16,
              question_text: 'CURRECURRENT DISABILITY(IES). Line 1 of 15.'
            },
            'line2': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[1]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 2 of 15.'
            },
            'line3': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[2]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 3 of 15.'
            },
            'line4': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[3]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 4 of 15.'
            },
            'line5': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[4]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 5 of 15.'
            },
            'line6': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[5]',
              question_num: 16,
              queston_text: 'DISABILITY. Line 6 of 15.'
            },
            'line7': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[6]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 7 of 15.'
            },
            'line8': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[7]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 8 of 15.'
            },
            'line9': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[8]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 9 of 15.'
            },
            'line10': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[9]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 10 of 15.'
            },
            'line11': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[10]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 11 of 15.'
            },
            'line12': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[11]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 12 of 15.'
            },
            'line13': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[12]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 13 of 15.'
            },
            'line14': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[13]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 14 of 15.'
            },
            'line15': {
              key: 'F[0].Page_10[0].CURRENTDISABILITY[14]',
              question_num: 16,
              queston_text: 'CURRENT DISABILITY. Line 15 of 15.'
            }
          },
          'classificationCode': {
          },
          'approximateBeginDate': {
          },
          'secondaryDisabilities': {
            'name': {
            },
            'disabilityActionType': {
            },
            'serviceRelevance': {
            },
            'specialIssues': {
            },
            'classificationCode': {
            },
            'approximateBeginDate': {
            }
          }
        },
        'treatments': {
          'startDate': {
            'line1': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[0]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[0]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            },
            'line2': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[1]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: '',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            },
            'line3': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[2]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[2]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            },
            'line4': {
              'month': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Month[3]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 2 digit Month.'
              },
              'year': {
                key: 'F[0].#subform[9].Date_Of_Treatment_Year[3]',
                question_num: 17,
                question_suffix: 'B',
                question_text: 'DATE OF TREATMENT. Enter 4 digit year.'
              }
            }
          },
          'endDate': {
          },
          'treatedDisabilityNames': {
            'items': {
            }
          },
          'center': {
            question_num: 17,
            question_text: 'LIST V. A. MEDICAL CENTER(S) (VAMC) AND DEPARTMENT OF DEFENSE (D O D) MILITARY TREATMENT FACILITIES (M T F) WHERE YOU RECEIVED TREATMENT AFTER DISCHARGE FOR YOUR CLAIMED DISABILITY(IES) LISTED IN ITEM 16 AND PROVIDE THE APPROXIMATE DATE (Month and Year) OF TREATMENT: NOTE: If treatment began from 2005 to present, you do not need to provide dates in Item 17. B. 17. A. Enter the Disability Treated and Name and Location of the Treatment Facility. Line 1 of 4.',
            'name': {
              'line1': {
                key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[0]',
                question_num: 17,
                question_suffix: 'A',
                question_text: 'Enter the Disability Treated and Name and Location of the Treatment Facility. Line 1 of 4.'
              },
              'line2': {
                key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[1]',
                question_num: 17,
                question_suffix: 'A',
                question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 2 of 4.'
              },
              'line3': {
                key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[2]',
                question_num: 17,
                question_suffix: 'A',
                question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 3 of 4.'
              },
              'line4': {
                key: 'F[0].#subform[9].Enter_Disability_Treated_And_Name_And_Location_Of_Treatment_Facility[3]',
                question_num: 17,
                question_suffix: 'A',
                question_text: 'Enter Disability Treated and Name and Location of the Treatment Facility. Line 4 of 4.'
              }
            },
            'country': {
            }
          }
        },
        'servicePay': {
          'waiveVABenefitsToRetainTrainingPay': {
            'checkbox': {
              key: 'F[0].#subform[10].Do_NOT_Pay_Me_VA_Compensation_I_Do_Not_Want_To_Receive_VA_Compensation_In_Lieu_Of_Training_Pay[0]',
              question_num: 28
            }
          },
          'waiveVABenefitsToRetainRetiredPay': {
            'checkbox': {
              key: 'F[0].#subform[10].Do_Not_Pay_Me_VA_Compensation_I_Do_Not_Want_To_Receive-VA_Compensation_In_Lieu_Of_Retired_Pay[0]',
              question_num: 26
            }
          },
          'militaryRetiredPay': {
            'receiving': {
              'checkbox': {
                'yes': {
                  key: 'F[0].#subform[10].Yes[0]',
                  question_num: 24,
                  question_suffix: 'A',
                  question_text: 'Are you receiving military retired pay? YES. (If "Yes" complete Items 24. C and 24. D).'
                },
                'no': {
                  key: 'F[0].#subform[10].NO[0]',
                  question_num: 24,
                  question_suffix: 'A',
                  question_text: 'NO.'
                }
              }
            },
            'willReceiveInFuture': {
              'checkbox': {
                'yes': {
                  key: 'F[0].#subform[10].Yes[1]',
                  question_num: 24,
                  question_suffix: 'B',
                  question_text: 'WILL YOU RECEIVE MILITARY RETIRED PAY IN THE FUTURE? YES. (If "Yes," explain below (e.g. future Reserve / National Guard retirement, pending M E B / P E B and also complete Items 24. C and 24. D).'
                },
                'no': {
                  key: 'F[0].#subform[10].NO[1]',
                  question_num: 24,
                  question_suffix: 'B',
                  question_text: 'NO.'
                }
              }
            },
            'futurePayExplanation': {
              key: 'F[0].#subform[10].ReceiveMilitaryRetiredPay[0]',
              limit: 20,
              question_num: 24,
              question_suffix: 'B',
              question_text: 'Explain.'
            },
            'payment': {
              'serviceBranch': {
                'checkbox': {
                  'army': {
                    key: 'F[0].#subform[10].Army[1]',
                    question_num: 24,
                    question_suffix: 'C',
                    question_text: 'Branch of Service (Check all that apply). Army.'
                  },
                  'navy': {
                    key: 'F[0].#subform[10].Navy[1]',
                    question_num: 24,
                    question_suffix: 'C',
                    question_text: 'Navy.'
                  },
                  'marine_corps': {
                    key: 'F[0].#subform[10].Marine_Corps[1]',
                    question_num: 24,
                    question_suffix: 'C',
                    question_text: 'Marine Corps.'
                  },
                  'air_force': {
                    key: 'F[0].#subform[10].Air_Force[1]',
                    question_num: 24,
                    question_suffix: 'C',
                    question_text: 'Air Force.'
                  },
                  'coast_guard': {
                    key: 'F[0].#subform[10].Coast_Guard[1]',
                    question_num: 24,
                    question_suffix: 'C',
                    question_text: 'Coast Guard.'
                  },
                  'space_force': {
                    key: 'F[0].#subform[10].Space_Force[1]',
                    question_num: 24,
                    question_suffix: 'C',
                    question_text: 'Space Force.'
                  }
                }
              },
              'amount': {
                'first_three_spaces': {
                  key: 'F[0].#subform[10].Monthly_Amount[0]',
                  limit: 3,
                  question_num: 24,
                  question_suffix: 'D',
                  question_text: 'MONTHLY AMOUNT IN DOLLARS. First 3 digit spaces.'
                },
                'last_three_spaces': {
                  key: 'F[0].#subform[10].Monthly_Amount[1]',
                  limit: 3,
                  question_num: 24,
                  question_suffix: 'D',
                  question_text: 'MONTHLY AMOUNT IN DOLLARS. Last 3 digit spaces.'
                }
              }
            },
            'willReceiveInfuture': {
              # duplicate of 'willReciveInFuture'
            }
          },
          'hasSeparationPay': {
            # seems to be a duplicate of ['separationPay']['received'] ?
          },
          'separationPay': {
            'received': {
              'checkbox': {
                'yes': {
                  key: 'F[0].#subform[10].Yes[2]',
                  question_num: 27,
                  question_suffix: 'A',
                  question_text: 'HAVE YOU EVER RECEIVED SEPARATION PAY, DISABILITY PAY, OR ANY OTHER LUMP SUM PAYMENT FROM YOUR BRANCH OF SERVICE? YES. If "Yes," complete Items 27. B through 27. D.'
                },
                'no': {
                  key: 'F[0].#subform[10].No[0]',
                  question_num: 27,
                  question_suffix: 'A',
                  question_text: 'NO.'
                }
              }
            },
            'payment': {
              'serviceBranch': {
                'checkbox': {
                  'army': {
                    key: 'F[0].#subform[10].Army[2]',
                    question_num: 27,
                    question_suffix: 'C',
                    question_text: 'Branch of Service (Check all that apply). Army.'
                  },
                  'navy': {
                    key: 'F[0].#subform[10].Navy[2]',
                    question_num: 27,
                    question_suffix: 'C',
                    question_text: 'Navy.'
                  },
                  'marine_corps': {
                    key: 'F[0].#subform[10].Marine_Corps[2]',
                    question_num: 27,
                    question_suffix: 'C',
                    question_text: 'Marine Corps.'
                  },
                  'air_force': {
                    key: 'F[0].#subform[10].Air_Force[2]',
                    question_num: 27,
                    question_suffix: 'C',
                    question_text: 'Air Force.'
                  },
                  'coast_guard': {
                    key: 'F[0].#subform[10].Coast_Guard[2]',
                    question_num: 27,
                    question_suffix: 'C',
                    question_text: 'Coast Guard.'
                  },
                  'space_force': {
                    key: 'F[0].#subform[10].Space_Force[2]',
                    question_num: 27,
                    question_suffix: 'C',
                    question_text: 'Space Force.'
                  }
                }
              },
              'amount': {
                'first_three_digists': {
                  key: 'F[0].#subform[10].Amount_Received_First_Three_Digits[0]',
                  limit: 3,
                  question_num: 27,
                  question_suffix: 'D',
                  question_text: 'AMOUNT RECEIVED (Provide pre-tax amount). First 3 digits.'
                },
                'last_three_digits': {
                  key: 'F[0].#subform[10].Amount_Received_Last_Three_Digits[0]',
                  limit: 3,
                  question_num: 27,
                  question_suffix: 'D',
                  question_text: 'AMOUNT RECEIVED (Provide pre-tax amount). Last 3 digits.'
                }
              }
            },
            'receivedDate': {
              'month': {
                key: 'F[0].#subform[10].DatePaymentReceived_Month[0]',
                question_num: 27,
                question_suffix: 'B',
                question_text: 'Date payment received. Enter 2 digit month.'
              },
              'day': {
                key: 'F[0].#subform[10].DatePaymentReceived_Day[0]',
                question_num: 27,
                question_suffix: 'B',
                question_text: 'Date payment received. Enter 2 digit day.'
              },
              'year': {
                key: 'F[0].#subform[10].DatePaymentReceived_Year[0]',
                question_num: 27,
                question_suffix: 'B',
                question_text: 'Date payment received. Enter 4 digit Year.'
              }
            }
          }
        },
        'directDeposit': {
          'accountType': {
            'checking': {
              key: 'F[0].#subform[10].Checking_Account[0]',
              question_num: 30,
              question_text: 'CHECKING ACCOUNT.'
            },
            'savings': {
              key: 'F[0].#subform[10].Savings_Account[0]',
              question_num: 30,
              question_text: 'SAVINGS ACCOUNT. '
            }
          },
          'accountNumber': {
            key: 'F[0].#subform[10].Account_Number[0]',
            limit: 15,
            question_num: 30,
            question_text: 'Account Number. Check only one box below and provide the account number. Enter account number.'
          },
          'routingNumber': {
            key: 'F[0].#subform[10].Routing_Or_Transit_Number[0]',
            limit: 9,
            question_num: 32,
            question_text: 'ROUTING OR TRANSIT NUMBER (The first nine numbers located at the bottom left of your check).'
          },
          'bankName': {
            key: 'F[0].#subform[10].Name_Of_Financial_Institution[0]',
            limit: 15,
            question_num: 31,
            question_text: 'NAME OF FINANCIAL INSTITUTION ( Provide the name of the bank where you want your direct deposit). Line 1 of 2.'
          }
        },
        'claimantCertification': {
        },
        'applicationExpirationDate': {
        },
        'autoCestPDFGenerationDisabled': {
        },
        'claimDate': {
          'month': {
            key: 'F[0].#subform[11].Date_Signed_Month[1]',
            limit: 2,
            question_num: 33,
            question_suffix: 'B',
            question_text: 'DATE SIGNED. Enter 2 digit month.'
          },
          'day': {
            key: 'F[0].#subform[11].Date_Signed_Day[1]',
            limit: 2,
            question_num: 33,
            question_suffix: 'B',
            question_text: 'DATE SIGNED. Enter 2 digit day.'
          },
          'year': {
            key: 'F[0].#subform[11].Date_Signed_Year[1]',
            limit: 4,
            question_num: 33,
            question_suffix: 'B',
            question_text: 'DATE SIGNED. Enter 4 digit Year.'
          }
        }
      }.freeze
      # rubocop:enable Layout/LineLength

      def merge_fields
        @form_data['changeOfAddress']['beginningDate'] = split_date(@form_data['changeOfAddress']['beginningDate'])
        @form_data['changeOfAddress']['endingDate'] = split_date(@form_data['changeOfAddress']['endingDate'])
        @form_data['claimDate'] = split_date(@form_data['claimDate'])

        @form_data['alternateNames'] = combine_previous_names(@form_data['alternateNames'])

        @form_data
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
