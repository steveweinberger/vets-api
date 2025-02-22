# frozen_string_literal: true

module AppealsApi
  module PdfConstruction
    module SupplementalClaim
      module V2
        class Structure
          MAX_NUMBER_OF_ISSUES_ON_MAIN_FORM = 7
          MAX_NUMBER_OF_EVIDENCE_LOCATIONS_FORM = 3

          def initialize(supplemental_claim)
            @supplemental_claim = supplemental_claim
          end

          # rubocop:disable Metrics/MethodLength
          def form_fill
            # Section I: Identifying Information
            # Name, address and email filled out through autosize text box, not pdf fields
            {
              form_fields.veteran_middle_initial => form_data.veteran_middle_initial,
              form_fields.ssn_first_three => form_data.ssn_first_three,
              form_fields.ssn_middle_two => form_data.ssn_middle_two,
              form_fields.ssn_last_four => form_data.ssn_last_four,
              form_fields.file_number => form_data.file_number,
              form_fields.veteran_dob_month => form_data.veteran_dob_month,
              form_fields.veteran_dob_day => form_data.veteran_dob_day,
              form_fields.veteran_dob_year => form_data.veteran_dob_year,
              form_fields.veteran_service_number => form_data.veteran_service_number,
              form_fields.insurance_policy_number => form_data.insurance_policy_number,

              form_fields.claimant_type => 1, # default to check 'veteran' for now

              form_fields.mailing_address_state => form_data.mailing_address_state,
              form_fields.mailing_address_country => form_data.mailing_address_country,
              form_fields.zip_code_5 => form_data.zip_code_5,
              form_fields.phone => form_data.phone,

              form_fields.benefit_type => form_data.benefit_type,

              # Section II: Issues (allows 7 in document fields)
              # Issues and dates filled out via text box
              form_fields.soc_ssoc_opt_in => form_data.soc_ssoc_opt_in,

              # Section III: New and Relevant Evidence
              # Name and Location, and Date text filled out through autosize text boxes

              # Section IV: 5103 Notice Acknowledgement
              form_fields.form_5103_notice_acknowledged => form_data.form_5103_notice_acknowledged,

              # Section V: Signatures
              # Signatures filled out through autosize text box, not pdf fields
              form_fields.date_signed => form_data.date_signed
            }
          end
          # rubocop:enable Metrics/MethodLength

          def insert_overlaid_pages(form_fill_path)
            pdftk = PdfForms.new(Settings.binaries.pdftk)

            output_path = "/tmp/#{supplemental_claim.id}-overlaid-form-fill-tmp.pdf"

            temp_path = fill_autosize_fields
            pdftk.multistamp(form_fill_path, temp_path, output_path)
            output_path
          end

          def add_additional_pages
            return unless additional_pages?

            @additional_pages_pdf ||= Prawn::Document.new(skip_page_creation: true)

            SupplementalClaim::Pages::V2::AdditionalPages.new(
              @additional_pages_pdf,
              form_data
            ).build!

            @additional_pages_pdf
          end

          def final_page_adjustments
            # Removes first 2 boilerplate pages
            ['3-end']
          end

          def form_title
            '200995'
          end

          def stamp(stamped_pdf_path)
            stamper = CentralMail::DatestampPdf.new(stamped_pdf_path)

            bottom_stamped_path = stamper.run(
              text: "API.VA.GOV #{supplemental_claim.created_at.utc.strftime('%Y-%m-%d %H:%M%Z')}",
              x: 5,
              y: 775,
              text_only: true
            )

            name_stamp_path = "#{Common::FileHelpers.random_file_path}.pdf"
            Prawn::Document.generate(name_stamp_path, margin: [0, 0]) do |pdf|
              pdf.text_box form_data.stamp_text,
                           at: [205, 785],
                           align: :center,
                           valign: :center,
                           overflow: :shrink_to_fit,
                           min_font_size: 8,
                           width: 215,
                           height: 10
            end

            CentralMail::DatestampPdf.new(nil).stamp(bottom_stamped_path, name_stamp_path)
          end

          private

          attr_accessor :supplemental_claim

          def default_text_opts
            { overflow: :shrink_to_fit,
              min_font_size: 8,
              valign: :bottom }.freeze
          end

          def form_fields
            @form_fields ||= SupplementalClaim::V2::FormFields.new
          end

          def form_data
            @form_data ||= SupplementalClaim::V2::FormData.new(supplemental_claim)
          end

          def fill_autosize_fields
            tmp_path = "/#{::Common::FileHelpers.random_file_path}.pdf"
            Prawn::Document.generate(tmp_path) do |pdf|
              2.times { pdf.start_new_page }

              pdf.font 'Courier'

              whiteout_line pdf, :veteran_first_name
              whiteout_line pdf, :veteran_last_name
              whiteout_line pdf, :mailing_address_number_and_street
              whiteout_line pdf, :email
              fill_contestable_issues_text pdf
              pdf.start_new_page

              pdf.text_box form_data.signature_of_veteran_claimant_or_rep,
                           default_text_opts.merge(form_fields.boxes[:signature_of_veteran_claimant_or_rep])
              pdf.text_box form_data.print_name_veteran_claimaint_or_rep,
                           default_text_opts.merge(form_fields.boxes[:print_name_veteran_claimaint_or_rep])

              fill_evidence_name_location_text pdf
              fill_new_evidence_dates pdf
            end
            tmp_path
          end

          def additional_pages?
            additional_issues? || additional_evidence_locations?
          end

          def additional_issues?
            form_data.contestable_issues.count > MAX_NUMBER_OF_ISSUES_ON_MAIN_FORM
          end

          def additional_evidence_locations?
            form_data.new_evidence_locations.count > MAX_NUMBER_OF_EVIDENCE_LOCATIONS_FORM
          end

          def fill_contestable_issues_text(pdf)
            issues = form_data.contestable_issues.take(MAX_NUMBER_OF_ISSUES_ON_MAIN_FORM)
            issues.first(MAX_NUMBER_OF_ISSUES_ON_MAIN_FORM).each_with_index do |issue, i|
              if issue.text_exists?
                pdf.text_box issue.text, default_text_opts.merge(form_fields.boxes[:contestable_issues][i])
                pdf.text_box issue.decision_date_string, default_text_opts.merge(form_fields.boxes[:decision_dates][i])
                pdf.text_box form_data.soc_date_text(issue), default_text_opts.merge(form_fields.boxes[:soc_dates][i])
              end
            end
          end

          def fill_evidence_name_location_text(pdf)
            locations = form_data.new_evidence_locations.take(MAX_NUMBER_OF_EVIDENCE_LOCATIONS_FORM)

            locations.first(MAX_NUMBER_OF_EVIDENCE_LOCATIONS_FORM).each_with_index do |location, i|
              pdf.text_box location, default_text_opts.merge(form_fields.boxes[:new_evidence_locations][i])
            end
          end

          def fill_new_evidence_dates(pdf)
            evidence_dates = form_data.new_evidence_dates.take(MAX_NUMBER_OF_EVIDENCE_LOCATIONS_FORM)

            evidence_dates.first(MAX_NUMBER_OF_EVIDENCE_LOCATIONS_FORM).each_with_index do |dates, i|
              dates.each_with_index do |date, date_index|
                x, y = form_fields.boxes[:new_evidence_dates][i][:at]
                y_offset = y - date_index * 9
                date_opts = form_fields.boxes[:new_evidence_dates][i].merge({ at: [x, y_offset], size: 8 })

                pdf.text_box date, default_text_opts.merge(date_opts)
              end
            end
          end

          def whiteout(pdf, at:, width:, height: 14)
            pdf.fill_color 'ffffff'
            pdf.fill_rectangle at, width, height
            pdf.fill_color '000000'
          end

          def whiteout_line(pdf, attr)
            text_opts = form_fields.boxes[attr].merge(default_text_opts).merge(height: 13)

            whiteout pdf, form_fields.boxes[attr]

            text = form_data.send(attr)
            pdf.text_box text, text_opts
          end
        end
      end
    end
  end
end
