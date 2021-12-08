# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckIn::V2::AppointmentDataSerializer do
  subject { described_class }

  before do
    allow(Flipper).to receive(:enabled?)
      .with(:check_in_experience_demographics_page_enabled).and_return(true)
  end

  let(:appointment_data) do
    {
      id: 'd602d9eb-9a31-484f-9637-13ab0b507e0d',
      scope: 'read.full',
      payload: {
        demographics: {
          nextOfKin1: {
            name: 'VETERAN,JONAH',
            relationship: 'BROTHER',
            phone: '1112223333',
            workPhone: '4445556666',
            address: {
              street1: '123 Main St',
              street2: 'Ste 234',
              street3: '',
              city: 'Los Angeles',
              county: 'Los Angeles',
              state: 'CA',
              zip: '90089',
              zip4: nil,
              country: 'USA'
            }
          },
          nextOfKin2: {
            name: '',
            relationship: '',
            phone: '',
            workPhone: '',
            address: {
              street1: '',
              street2: '',
              street3: '',
              city: '',
              county: nil,
              state: '',
              zip: '',
              zip4: nil,
              country: nil
            }
          },
          emergencyContact: {
            name: 'VETERAN,JONAH',
            relationship: 'BROTHER',
            phone: '1112223333',
            workPhone: '4445556666',
            address: {
              street1: '123 Main St',
              street2: 'Ste 234',
              street3: '',
              city: 'Los Angeles',
              county: 'Los Angeles',
              state: 'CA',
              zip: '90089',
              zip4: nil,
              country: 'USA'
            }
          },
          mailingAddress: {
            street1: '123 Turtle Trail',
            street2: '',
            street3: '',
            city: 'Treetopper',
            county: 'SAN BERNARDINO',
            state: 'Tennessee',
            zip: '101010',
            country: 'USA'
          },
          homeAddress: {
            street1: '445 Fine Finch Fairway',
            street2: 'Apt 201',
            street3: '',
            city: 'Fairfence',
            county: 'FOO',
            state: 'Florida',
            zip: '445545',
            country: 'USA'
          },
          homePhone: '5552223333',
          mobilePhone: '5553334444',
          workPhone: '5554445555',
          emailAddress: 'kermit.frog@sesameenterprises.us'
        },
        appointments: [
          {
            appointmentIEN: '1',
            patientDFN: '888',
            stationNo: '5625',
            zipCode: 'appointment.zipCode',
            clinicName: 'appointment.clinicName',
            startTime: '2021-08-19T10:00:00',
            clinicPhoneNumber: 'appointment.clinicPhoneNumber',
            clinicFriendlyName: 'appointment.patientFriendlyName',
            facility: 'appointment.facility',
            facilityId: 'some-id',
            appointmentCheckInStart: '2021-08-19T09:030:00',
            appointmentCheckInEnds: 'time checkin Ends',
            status: 'the status',
            timeCheckedIn: 'time the user checked already'
          },
          {
            appointmentIEN: '2',
            patientDFN: '888',
            stationNo: '5625',
            zipCode: 'appointment.zipCode',
            clinicName: 'appointment.clinicName',
            startTime: '2021-08-19T15:00:00',
            clinicPhoneNumber: 'appointment.clinicPhoneNumber',
            clinicFriendlyName: 'appointment.patientFriendlyName',
            facility: 'appointment.facility',
            facilityId: 'some-id',
            appointmentCheckInStart: '2021-08-19T14:30:00',
            appointmentCheckInEnds: 'time checkin Ends',
            status: 'the status',
            timeCheckedIn: 'time the user checked already'
          }
        ]
      }
    }
  end

  describe '#serializable_hash' do
    let(:serialized_hash_response) do
      {
        data: {
          id: 'd602d9eb-9a31-484f-9637-13ab0b507e0d',
          type: :appointment_data,
          attributes: {
            payload: {
              demographics: {
                mailingAddress: {
                  street1: '123 Turtle Trail',
                  street2: '',
                  street3: '',
                  city: 'Treetopper',
                  county: 'SAN BERNARDINO',
                  state: 'Tennessee',
                  zip: '101010',
                  country: 'USA'
                },
                homeAddress: {
                  street1: '445 Fine Finch Fairway',
                  street2: 'Apt 201',
                  street3: '',
                  city: 'Fairfence',
                  county: 'FOO',
                  state: 'Florida',
                  zip: '445545',
                  country: 'USA'
                },
                homePhone: '5552223333',
                mobilePhone: '5553334444',
                workPhone: '5554445555',
                emailAddress: 'kermit.frog@sesameenterprises.us'
              },
              appointments: [
                {
                  appointmentIEN: '1',
                  zipCode: 'appointment.zipCode',
                  clinicName: 'appointment.clinicName',
                  startTime: '2021-08-19T10:00:00',
                  clinicPhoneNumber: 'appointment.clinicPhoneNumber',
                  clinicFriendlyName: 'appointment.patientFriendlyName',
                  facility: 'appointment.facility',
                  facilityId: 'some-id',
                  appointmentCheckInStart: '2021-08-19T09:030:00',
                  appointmentCheckInEnds: 'time checkin Ends',
                  status: 'the status',
                  timeCheckedIn: 'time the user checked already'
                },
                {
                  appointmentIEN: '2',
                  zipCode: 'appointment.zipCode',
                  clinicName: 'appointment.clinicName',
                  startTime: '2021-08-19T15:00:00',
                  clinicPhoneNumber: 'appointment.clinicPhoneNumber',
                  clinicFriendlyName: 'appointment.patientFriendlyName',
                  facility: 'appointment.facility',
                  facilityId: 'some-id',
                  appointmentCheckInStart: '2021-08-19T14:30:00',
                  appointmentCheckInEnds: 'time checkin Ends',
                  status: 'the status',
                  timeCheckedIn: 'time the user checked already'
                }
              ]
            }
          }
        }
      }
    end

    context 'with next of kin flag turned off' do
      it 'returns a serialized hash without next of kin' do
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_emergency_contact_enabled).and_return(false)
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_next_of_kin_enabled).and_return(false)

        appt_struct = OpenStruct.new(appointment_data)
        appt_serializer = CheckIn::V2::AppointmentDataSerializer.new(appt_struct)

        expect(appt_serializer.serializable_hash).to eq(serialized_hash_response)
      end
    end

    context 'with next of kin flag turned on' do
      let(:next_of_kin_data) do
        {
          data: {
            attributes: {
              payload: {
                demographics: {
                  nextOfKin1: {
                    name: 'VETERAN,JONAH',
                    relationship: 'BROTHER',
                    phone: '1112223333',
                    workPhone: '4445556666',
                    address: {
                      street1: '123 Main St',
                      street2: 'Ste 234',
                      street3: '',
                      city: 'Los Angeles',
                      county: 'Los Angeles',
                      state: 'CA',
                      zip: '90089',
                      zip4: nil,
                      country: 'USA'
                    }
                  }
                }
              }
            }
          }
        }
      end
      let(:serialized_hash_response_with_next_of_kin) do
        serialized_hash_response.deep_merge(next_of_kin_data)
      end

      it 'returns a serialized hash with next of kin' do
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_emergency_contact_enabled).and_return(false)
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_next_of_kin_enabled).and_return(true)

        appt_struct = OpenStruct.new(appointment_data)
        appt_serializer = CheckIn::V2::AppointmentDataSerializer.new(appt_struct)

        expect(appt_serializer.serializable_hash).to eq(serialized_hash_response_with_next_of_kin)
      end
    end

    context 'with emergency contact flag turned off' do
      it 'returns a serialized hash without emergency contact' do
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_next_of_kin_enabled).and_return(false)
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_emergency_contact_enabled).and_return(false)

        appt_struct = OpenStruct.new(appointment_data)
        appt_serializer = CheckIn::V2::AppointmentDataSerializer.new(appt_struct)

        expect(appt_serializer.serializable_hash).to eq(serialized_hash_response)
      end
    end

    context 'with emergency contact flag turned on' do
      let(:emergency_contact_data) do
        {
          data: {
            attributes: {
              payload: {
                demographics: {
                  emergencyContact: {
                    name: 'VETERAN,JONAH',
                    relationship: 'BROTHER',
                    phone: '1112223333',
                    workPhone: '4445556666',
                    address: {
                      street1: '123 Main St',
                      street2: 'Ste 234',
                      street3: '',
                      city: 'Los Angeles',
                      county: 'Los Angeles',
                      state: 'CA',
                      zip: '90089',
                      zip4: nil,
                      country: 'USA'
                    }
                  }
                }
              }
            }
          }
        }
      end
      let(:serialized_hash_response_with_emergency_contact) do
        serialized_hash_response.deep_merge(emergency_contact_data)
      end

      it 'returns a serialized hash with emergency contact' do
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_next_of_kin_enabled).and_return(false)
        allow(Flipper).to receive(:enabled?)
          .with(:check_in_experience_emergency_contact_enabled).and_return(true)

        appt_struct = OpenStruct.new(appointment_data)
        appt_serializer = CheckIn::V2::AppointmentDataSerializer.new(appt_struct)

        expect(appt_serializer.serializable_hash).to eq(serialized_hash_response_with_emergency_contact)
      end
    end
  end
end
