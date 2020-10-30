# frozen_string_literal: true

require 'pp'
require 'set'

namespace :form526 do
  desc 'Get all submissions within a date period. [<start date: yyyy-mm-dd>,<end date: yyyy-mm-dd>]'
  task :submissions, %i[start_date end_date] => [:environment] do |_, args|
    # This forces string token formatting. Our examples don't match
    # what this style is enforcing
    # rubocop: format('%<greeting>s', greeting: 'Hello')
    # vets-api example: printf "%-20s %s\n", header, total

    def print_row(created_at, updated_at, id, c_id, p_id, complete, version)
      printf "%-24s %-24s %-15s %-10s %-15s %-18s %s\n", created_at, updated_at, id, c_id, p_id, complete, version
    end

    def print_total(header, total)
      printf "%-20s %s\n", header, total
    end

    start_date = args[:start_date]&.to_date || 30.days.ago.utc
    end_date = args[:end_date]&.to_date || Time.zone.now.utc

    puts '------------------------------------------------------------'
    print_row(
      'created at:', 'updated at:', 'submission id:', 'claim id:',
      'participant id:', 'workflow complete:', 'form version:'
    )

    submissions = Form526Submission.where(
      'created_at BETWEEN ? AND ?', start_date.beginning_of_day, end_date.end_of_day
    )

    outage_errors = 0
    ancillary_job_errors = Hash.new { |hash, job_class| hash[job_class] = 0 }
    other_errors = 0

    # Scoped order are ignored for find_each. Its forced to be batch order (on primary key)
    # This should be fine as created_at dates correlate directly to PKs
    submissions.find_each do |submission|
      submission.form526_job_statuses.where.not(error_message: [nil, '']).each do |job_status|
        if job_status.job_class == 'SubmitForm526AllClaim'
          job_status.error_message.include?('.serviceError') ? (outage_errors += 1) : (other_errors += 1)
        else
          ancillary_job_errors[job_status.job_class] += 1
        end
      end
      version = submission.bdd? ? 'BDD' : 'ALL'
      print_row(
        submission.created_at, submission.updated_at, submission.id, submission.submitted_claim_id,
        submission.auth_headers['va_eauth_pid'], submission.workflow_complete, version
      )
    end

    total_jobs = submissions.count
    success_jobs = submissions.group(:workflow_complete).count[true] || 0
    fail_jobs = total_jobs - success_jobs

    puts '------------------------------------------------------------'
    puts "* Job Success/Failure counts between #{start_date} - #{end_date} *"
    print_total('Total Jobs: ', total_jobs)
    print_total('Successful Jobs: ', success_jobs)
    print_total('Failed Jobs: ', fail_jobs)
    puts '------------------------------------------------------------'
    puts '* Failure Counts for form526 Submission Job (not including uploads/cleanup/etc...) *'
    print_total('Outage Failures: ', outage_errors)
    print_total('Other Failures: ', other_errors)
    puts 'Ancillary Job Errors:'
    ancillary_job_errors.each do |class_name, error_count|
      puts "    #{class_name}: #{error_count}"
    end
  end

  desc 'Get an error report within a given date period. [<start date: yyyy-mm-dd>,<end date: yyyy-mm-dd>,<flag>]'
  task :errors, %i[start_date end_date flag] => [:environment] do |_, args|
    def print_row(sub_id, p_id, created_at, is_bdd, job_class)
      printf "%-15s %-16s  %-25s %-10s %-20s\n", sub_id, p_id, created_at, is_bdd, job_class
    end

    def print_errors(errors)
      errors.sort_by { |_message, hash| -hash[:submission_ids].length }.each do |(k, v)|
        puts k
        puts '*****************'
        puts "Unique Participant ID count: #{v[:participant_ids].count}"
        print_row('submission_id:', 'participant_id:', 'created_at:', 'is_bdd?', 'job_class')
        v[:submission_ids].each do |submission|
          print_row(submission[:sub_id],
                    submission[:p_id],
                    submission[:date],
                    submission[:is_bdd],
                    submission[:job_class])
        end
        puts '*****************'
        puts ''
      end
    end

    def clean_message(msg)
      if msg[1].present?
        # strip the GUID from BGS errors for grouping purposes
        "#{msg[0]}: #{msg[1].gsub(/GUID.*/, '')}"
      else
        msg[0]
      end
    end

    # This regex will parse out the errors returned from EVSS.
    # The error message will be in an ugly stringified hash. There can be multiple
    # errors in a message. Each error will have a `key` and a `text` key. The
    # following regex will group all key/text pairs together that are present in
    # the string.
    MSGS_REGEX = /key\"=>\"(.*?)\".*?text\"=>\"(.*?)\"/.freeze

    start_date = args[:start_date]&.to_date || 30.days.ago.utc
    end_date = args[:end_date]&.to_date || Time.zone.now.utc

    errors = Hash.new { |hash, message_name| hash[message_name] = { submission_ids: [], participant_ids: Set[] } }

    submissions = Form526Submission.where(
      'created_at BETWEEN ? AND ?', start_date.beginning_of_day, end_date.end_of_day
    )

    submissions.find_each do |submission|
      job_statuses = submission.form526_job_statuses.where.not(status: [Form526JobStatus::STATUS[:try],
                                                                        Form526JobStatus::STATUS[:success]])
      job_statuses.each do |job_status|
        # Check if its an EVSS error and parse, otherwise store the entire message
        messages = if job_status.error_message.include?('=>') &&
                      job_status.error_class != 'Common::Exceptions::BackendServiceException'
                     job_status.error_message.gsub(/\[(\d*)\]|\\/, '').scan(MSGS_REGEX)
                   else
                     [[job_status.error_message]]
                   end
        messages.each do |msg|
          message = clean_message(msg)
          errors[message][:submission_ids].append(
            sub_id: submission.id,
            p_id: submission.auth_headers['va_eauth_pid'],
            date: submission.created_at,
            is_bdd: submission.bdd?,
            job_class: job_status.job_class
          )
          errors[message][:participant_ids].add(submission.auth_headers['va_eauth_pid'])
        end
      end
    end

    if args[:flag]&.downcase&.include?('j')
      puts errors.to_json
      next
    end

    puts '------------------------------------------------------------'
    puts "* Form526 Submission Errors from #{start_date} to #{end_date} *"
    puts '------------------------------------------------------------'
    puts ''
    print_errors(errors)
  end

  desc 'Get one or more submission details given an array of ids (either submission_ids or job_ids)'
  task submission: :environment do |_, args|
    raise 'No submission ids provided' unless args.extras.count.positive?

    def integer?(obj)
      obj.to_s == obj.to_i.to_s
    end
    Rails.application.eager_load!

    args.extras.each do |id|
      submission = if integer?(id)
                     Form526Submission.find(id)
                   else
                     Form526JobStatus.where(job_id: id).first.form526_submission
                   end

      saved_claim_form = submission.saved_claim.parsed_form
      saved_claim_form['veteran'] = 'FILTERED'

      submitted_claim_form = submission.form
      submitted_claim_form['form526']['form526']['directDeposit'] = 'FILTERED'
      submitted_claim_form['form526']['form526']['veteran'] = 'FILTERED'

      auth_headers = JSON.parse(submission.auth_headers_json)
      # There have been prod instances of users not having a ssn
      ssn = auth_headers['va_eauth_pnid'] || ''

      puts '------------------------------------------------------------'
      puts "Submission (#{submission.id}):\n\n"
      puts "user uuid: #{submission.user_uuid}"
      puts "user edipi: #{auth_headers['va_eauth_dodedipnid']}"
      puts "user participant id: #{auth_headers['va_eauth_pid']}"
      puts "user ssn: #{ssn.gsub(/(?=\d{5})\d/, '*')}"
      puts "saved claim id: #{submission.saved_claim_id}"
      puts "submitted claim id: #{submission.submitted_claim_id}"
      puts "workflow complete: #{submission.workflow_complete}"
      puts "created at: #{submission.created_at}"
      puts "updated at: #{submission.updated_at}"
      puts "\n"
      puts '----------------------------------------'
      puts "Jobs:\n\n"
      submission.form526_job_statuses.each do |s|
        puts s.job_class.to_s
        puts "  status: #{s.status}"
        puts "  error: #{s.error_class}" if s.error_class
        puts "    message: #{s.error_message}" if s.error_message
        puts "  updated at: #{s.updated_at}"
        puts "\n"
      end
      puts '----------------------------------------'
      puts "Form From User JSON:\n\n"
      puts JSON.pretty_generate(saved_claim_form)
      puts "\n\n"
      puts '----------------------------------------'
      puts "Translated form for EVSS JSON:\n\n"
      puts JSON.pretty_generate(submitted_claim_form)
      puts "\n\n"
    end
  end

  # EVSS has asked us to re-upload files that were corrupted upstream
  desc 'Resubmit uploads to EVSS for submitted claims given an array of saved_claim_ids'
  task retry_corrupted_uploads: :environment do |_, args|
    raise 'No saved_claim_ids provided' unless args.extras.count.positive?

    form_submissions = Form526Submission.where(saved_claim_id: args.extras)
    form_submissions.each do |form_submission|
      form_submission.send(:submit_uploads)
      puts "reuploaded files for saved_claim_id #{form_submission.saved_claim_id}"
    end
    puts "reuploaded files for #{form_submissions.count} submissions"
  end

  desc 'form 526 stats  [<start date: yyyy-mm-dd>,<end date: yyyy-mm-dd>]'
  task :stats, %i[start_date end_date] => [:environment] do |_, _args|
    # start_date = args[:start_date]&.to_date || 31.days.ago.utc
    # end_date = args[:end_date]&.to_date || 1.day.ago.utc

    def percent_of(n, d)
      return '0%' if n.zero?

      "#{n / d * 100.0}%"
    end

    start_date = 31.days.ago.utc
    end_date = 1.day.ago.utc

    submissions = Form526Submission.where(
      'created_at BETWEEN ? AND ?', start_date.beginning_of_day, end_date.end_of_day
    )

    in_progress_forms = InProgressForm.where('updated_at BETWEEN ? AND ?',
                                             start_date.beginning_of_day,
                                             end_date.end_of_day)
                                      .where(form_id: '21-526EZ')
    in_progress_forms_count = in_progress_forms.count
    return_url_data = in_progress_forms
                      .select("CAST(metadata -> 'return_url' AS text) as return_url, count(*) as the_count")
                      .group('return_url')
                      .order('the_count')
    return_urls = return_url_data.collect { |r| [r.the_count, r.return_url] }.sort_by { |s| s[0] }.join("\n")

    failed_submissions = submissions.where(workflow_complete: false)
    successful_submissions = submissions.where(workflow_complete: true)
    unique_submission_count = submissions.distinct(:user_uuid).count
    uniq_success_subs = successful_submissions.distinct(:user_uuid).count
    unique_failed_submissions = failed_submissions.distinct(:user_uuid).count
    ultimately_successful = unique_failed_submissions + uniq_success_subs - unique_submission_count
    ultimately_blocked =  unique_failed_submissions - ultimately_successful
    completion_rate = percent_of(successful_submissions.count, in_progress_forms_count + successful_submissions.count)

    puts '-- Form526Submission Totals ----------------------------------------------------------'
    puts "* Counts between #{start_date} - #{end_date} *"
    puts "Total Submissions: #{submissions.count}"
    puts "Successful Submissions: #{successful_submissions.count} "\
      "#{percent_of(successful_submissions.count, submissions.count)}"
    puts "Failed Submissions: #{failed_submissions.count} #{percent_of(failed_submissions.count, submissions.count)}"
    puts '-- Form526Submission Totals by Unique Veterans ----------------------------------------------------------'
    puts "Total Submissions: #{unique_submission_count}"
    puts "Successful Submissions: #{uniq_success_subs} #{percent_of(uniq_success_subs, unique_submission_count)}"
    puts "Failed Submissions: #{unique_failed_submissions}  "\
        "#{percent_of(unique_failed_submissions, unique_submission_count)}"
    puts "Users who succeded after a failed submission #{ultimately_successful} "\
         "#{percent_of(ultimately_successful, unique_submission_count)}"
    puts "Users who did not have a successful submission #{ultimately_blocked} "\
         "#{percent_of(ultimately_blocked, unique_submission_count)}"
    puts '------------------------------------------------------------'

    puts "21-526EZ InProgressForm Count: #{in_progress_forms_count}"

    puts "Completion rate #{completion_rate}"

    puts "Last page before abandon \n #{return_urls}"
  end
end
