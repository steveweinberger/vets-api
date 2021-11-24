# frozen_string_literal: true

module Swagger
  module Requests
    class MedicalCopays
      include Swagger::Blocks

      swagger_path '/v0/medical_copays' do
        operation :get do
          key :description, 'List of user copays for VA facilities'
          key :operationId, 'getMedicalCopays'
          key :tags, %w[medical_copays]

          parameter :authorization

          response 200 do
            key :description, 'Successful copays lookup'
            schema do
              key :required, %i[data status]
              property :data, type: :array do
                items do
                  property :id, type: :string, example: '3fa85f64-5717-4562-b3fc-2c963f66afa6'
                  property :pSSeqNum, type: :integer, example: 0
                  property :pSTotSeqNum, type: :integer, example: 0
                  property :pSFacilityNum, type: :string
                  property :pSFacPhoneNum, type: :string
                  property :pSTotStatement, type: :integer, example: 0
                  property :pSStatementVal, type: :string
                  property :pSStatementDate, type: :string
                  property :pSStatementDateOutput, type: :string
                  property :pSProcessDate, type: :string
                  property :pSProcessDateOutput, type: :string
                  property :pHPatientLstNme, type: :string
                  property :pHPatientFstNme, type: :string
                  property :pHPatientMidNme, type: :string
                  property :pHAddress1, type: :string
                  property :pHAddress2, type: :string
                  property :pHAddress3, type: :string
                  property :pHCity, type: :string
                  property :pHState, type: :string
                  property :pHZipCde, type: :string
                  property :pHZipCdeOutput, type: :string
                  property :pHCtryNme, type: :string
                  property :pHAmtDue, type: :integer, example: 0
                  property :pHAmtDueOutput, type: :string
                  property :pHPrevBal, type: :integer, example: 0
                  property :pHPrevBalOutput, type: :string
                  property :pHTotCharges, type: :integer, example: 0
                  property :pHTotChargesOutput, type: :string
                  property :pHTotCredits, type: :integer, example: 0
                  property :pHTotCreditsOutput, type: :string
                  property :pHNewBalance, type: :integer, example: 0
                  property :pHNewBalanceOutput, type: :string
                  property :pHSpecialNotes, type: :string
                  property :pHROParaCdes, type: :string
                  property :pHNumOfLines, type: :integer, example: 0
                  property :pHDfnNumber, type: :integer, example: 0
                  property :pHCernerStatementNumber, type: :integer, example: 0
                  property :pHCernerPatientId, type: :string
                  property :pHCernerAccountNumber, type: :string
                  property :pHIcnNumber, type: :string
                  property :pHAccountNumber, type: :integer, example: 0
                  property :pHLargeFontIndcator, type: :integer, example: 0
                  property :details, type: :array do
                    items do
                      property :pDDatePosted, type: :string
                      property :pDDatePostedOutput, type: :string
                      property :pDTransDesc, type: :string
                      property :pDTransDescOutput, type: :string
                      property :pDTransAmt, type: :integer, example: 0
                      property :pDTransAmtOutput, type: :string
                      property :pDRefNo, type: :string
                    end
                  end
                  property :station, type: :object do
                    property :facilitYNum, type: :string
                    property :visNNum, type: :string
                    property :facilitYDesc, type: :string
                    property :cyclENum, type: :string
                    property :remiTToFlag, type: :string
                    property :maiLInsertFlag, type: :string
                    property :staTAddress1, type: :string
                    property :staTAddress2, type: :string
                    property :staTAddress3, type: :string
                    property :city, type: :string
                    property :state, type: :string
                    property :ziPCde, type: :string
                    property :ziPCdeOutput, type: :string
                    property :baRCde, type: :string
                    property :teLNumFlag, type: :string
                    property :teLNum, type: :string
                    property :teLNum2, type: :string
                    property :contacTInfo, type: :string
                    property :dM2TelNum, type: :string
                    property :contacTInfo2, type: :string
                    property :toPTelNum, type: :string
                    property :lbXFedexAddress1, type: :string
                    property :lbXFedexAddress2, type: :string
                    property :lbXFedexAddress3, type: :string
                    property :lbXFedexCity, type: :string
                    property :lbXFedexState, type: :string
                    property :lbXFedexZipCde, type: :string
                    property :lbXFedexBarCde, type: :string
                    property :lbXFedexContact, type: :string
                    property :lbXFedexContactTelNum, type: :string
                  end
                end
              end
              property :status, type: :integer, example: 200
            end
          end
        end
      end

      swagger_path '/v0/medical_copays/get_pdf_statement_by_id/{id}' do
        operation :get do
          key :description, 'Endpoint to get PDF statement by medical_copay id'
          key :operationId, 'getPDFStatementsById'
          key :tags, %w[medical_copays]

          parameter :authorization

          parameter do
            key :name, :id
            key :in, :path
            key :description, 'The type of letter to be downloaded'
            key :required, true
            key :type, :string
          end

          response 200 do
            key :description, 'Successful PDF retrival'
            schema do
              key :required, %i[data status]

              property :data, type: :object do
                key :required, [:attributes]

                property :type do
                  key :description, 'ID for coorisponding PDF to be downloaded'
                  key :type, :string
                  key :example, 'PDF'
                end

                property :statement do
                  key :description, 'PDF payload for frontend to allow users to download'
                  key :type, :string
                  key :example,
                      'JVBERi0xLjQKMSAwIG9iago8PAovVGl0bGUgKP7/AFYAQgBTACAAUwB0AGEAdABlAG0AZQBuAHQAIABmAG8AcgAgAFQAUgBBA
                      FYASQBTACAASgBPAE4ARQBTKQovQ3JlYXRvciAo/v8AdwBrAGgAdABtAGwAdABvAHAAZABmACAAMAAuADEAMgAuADQpCi9Qcm9
                      kdWNlciAo/v8AUQB0ACAANAAuADgALgA3KQovQ3JlYXRpb25EYXRlIChEOjIwMjExMTA1MTQyOTU2WikKPj4KZW5kb2JqCjMgM
                      CBvYmoKPDwKL1R5cGUgL0V4dEdTdGF0ZQovU0EgdHJ1ZQovU00gMC4wMgovY2EgMS4wCi9DQSAxLjAKL0FJUyBmYWxzZQovU01
                      hc2sgL05vbmU+PgplbmRvYmoKNCAwIG9iagpbL1BhdHRlcm4gL0RldmljZVJHQl0KZW5kb2JqCjggMCBvYmoKPDwKL1R5cGUgL
                      0Fubm90Ci9TdWJ0eXBlIC9MaW5rCi9SZWN0IFs0NTAuNzUwMDAwICA3NTIuNzUwMDAwICA0OTYuNTAwMDAwICA3NjEgXQovQm9
                      yZGVyIFswIDAgMF0KL0EgPDwKL1R5cGUgL0FjdGlvbgovUyAvVVJJCi9VUkkgKGh0dHA6Ly93d3cucGF5LmdvdikKPj4KPj4KZ
                      W5kb2JqCjUgMCBvYmoKPDwKL1R5cGUgL1BhZ2UKL1BhcmVudCAyIDAgUgovQ29udGVudHMgOSAwIFIKL1Jlc291cmNlcyAxMSA
                      wIFIKL0Fubm90cyAxMiAwIFIKL01lZGlhQm94IFswIDAgNTk2IDg0Ml0KPj4KZW5kb2JqCjExIDAgb2JqCjw8Ci9Db2xvclNwY
                      WNlIDw8Ci9QQ1NwIDQgMCBSCi9DU3AgL0RldmljZVJHQgovQ1NwZyAvRGV2aWNlR3JheQo+PgovRXh0R1N0YXRlIDw8Ci9HU2E
                      gMyAwIFIKPj4KL1BhdHRlcm4gPDwKPj4KL0ZvbnQgPDwKL0Y2IDYgMCBSCi9GNyA3IDAgUgo+PgovWE9iamVjdCA8PAo+Pgo+P
                      gplbmRvYmoKMTIgMCBvYmoKWyA4IDAgUiBdCmVuZG9iago5IDAgb2JqCjw8Ci9MZW5ndGggMTAgMCBSCi9GaWx0ZXIgL0ZsYXR
                      lRGVjb2RlCj4+CnN0cmVhbQp4nO1dTY8cOXK996+o8wKq4TeZgGFA3VIb8MGAMAL2YPhgzO54sdAMPLsH/32TzCQzi8zHqqKC1
                      SWpRsBIXex6DMYXI8gg+dO//fzfh//55+Gnl5//9/DL8vfLz0/saDWb/zuEP++2H3B1FPMPByfs0nD45benPw5/PH16+uT/H/7
                      +4ymhzhj//OX3p5/m/p7mT35++Q//r/87iMO/+5/+fvjP//J//WWBCL/w25OV+jiF/6T/8cv2R86cOk5WceU/Z+WP4Zf/9vTnP
                      x1+93SwoyfROCaMnWkpfvakd5O6GaXnhJgU59bAf2+BL6JrOijDDkJMB8sO//jr06++y6EdCulyl0LfpEvl/3njLs1kml0665T
                      k0gr47+sl6fuJXRp1K1ly7hb9kfxWnJ0OWrLDxM1Bitt06AcWugx8vVGXka+xT8/Xuk8e//RwzoiZcxMVZOCNB428oQKdRx9Qw
                      +jJSD0YxufRO8LRB9A4eirQOPqIGkZPRurBeE7Sj96DDhh9QCUevbUDRu9BB4w+oJKO3pNquZ5JtZSkRtRAKhVqJFWLEaRqMYB
                      UN40g1U30pDphBpAaUclJNXIEqQGVmtSJsQGkRlRyUqUdQaq0A0i1agSpAZWaVM44H0DrDEtPrHJDiA2w9MS6EVPWDEtOLBcjJ
                      q0Zlp5YPWLammHpiZ1GTFwzLDmxQo6YumZYemLtiMlrhiUnVrIR09cMS0+sGjGBzbCkxHpM57+pwmzDq6WN+Kd3RVGyAy0i9+k
                      GEWBegyQkMi8yEmLmVURKZuZlQk2GuVkHFIRSD+nlnrb3A2pBDBjMkhIwJFS0gD7tIQUMyQktoMeiBfSBPilgjMaJEX3ITIzoi
                      I0lBp/'
                end
              end
            end
          end
        end
      end
    end
  end
end
