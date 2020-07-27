# frozen_string_literal: true

module BGS
  class Dependents
    def initialize(proc_id:, payload:, user:)
      @proc_id = proc_id
      @payload = payload
      @dependents = []
      @dependents_application = @payload['dependents_application']
      @user = user
    end

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def create
      report_674 if @payload['report674']
      add_children if @payload['add_child']
      report_deaths if @payload['report_death']
      report_divorce if @payload['report_divorce']
      report_stepchild if @payload['report_stepchild_not_in_household']
      report_child_event('child_marriage') if @payload['report_marriage_of_child_under18']
      report_child_event('not_attending_school') if @payload['report_child18_or_older_is_not_attending_school']

      @dependents
    end

    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def add_children
      @dependents_application['children_to_add'].each do |child_info|
        child = BGS::DependentEvents::Child.new(child_info)
        formatted_info = child.format_info
        participant = bgs_service.create_participant(@proc_id)

        bgs_service.create_person(@proc_id, participant[:vnp_ptcpnt_id], formatted_info)
        bgs_service.generate_address(
          @proc_id,
          participant[:vnp_ptcpnt_id],
          child.address(@dependents_application)
        )

        @dependents << child.serialize_dependent_result(
          participant,
          'Child',
          formatted_info['family_relationship_type'],
          {
            marriage_termination_type_code: formatted_info['reason_marriage_ended'],
            type: 'child'
          }
        )
      end
    end

    def report_deaths
      @dependents_application['deaths'].each do |death_info|
        death = BGS::DependentEvents::Death.new(death_info)
        formatted_death_info = death.format_info
        relationship_types = death.relationship_type(death_info)
        death_info['location']['state_code'] = death_info['location'].delete('state')

        participant = bgs_service.create_participant(@proc_id)
        bgs_service.create_person(@proc_id, participant[:vnp_ptcpnt_id], formatted_death_info)
        # I think we need the death_location instead of creating an address
        # There is no support in the API for death location
        # create_address(@proc_id, participant[:vnp_ptcpnt_id], death_info['location'])

        @dependents << death.serialize_dependent_result(
          participant,
          relationship_types[:participant],
          relationship_types[:family],
          { type: 'death' }
        )
      end
    end

    def report_divorce
      divorce = BGS::DependentEvents::Divorce.new(@dependents_application['report_divorce'])
      divorce_info = divorce.format_info
      participant = bgs_service.create_participant(@proc_id)
      bgs_service.create_person(@proc_id, participant[:vnp_ptcpnt_id], divorce_info)

      @dependents << divorce.serialize_dependent_result(
        participant,
        'Spouse',
        'Spouse',
        {
          divorce_state: divorce_info['divorce_state'],
          divorce_city: divorce_info['divorce_city'],
          marriage_termination_type_code: divorce_info['marriage_termination_type_code']
        }
      )
    end

    def report_stepchild
      @dependents_application['step_children'].each do |stepchild_info|
        step_child = BGS::DependentEvents::StepChild.new(stepchild_info)
        step_child_formatted = step_child.format_info
        participant = bgs_service.create_participant(@proc_id)
        bgs_service.create_person(@proc_id, participant[:vnp_ptcpnt_id], step_child_formatted)
        bgs_service.generate_address(@proc_id, participant[:vnp_ptcpnt_id], stepchild_info['address'])

        @dependents << step_child.serialize_dependent_result(
          participant,
          'Child',
          'Stepchild',
          {
            living_expenses_paid: step_child_formatted['living_expenses_paid'],
            'type': 'stepchild'
          }
        )
      end
    end

    def report_child_event(event_type)
      child_event = child_event_type(event_type)
      formatted_child_info = child_event.format_info
      participant = bgs_service.create_participant(@proc_id)

      bgs_service.create_person(@proc_id, participant[:vnp_ptcpnt_id], formatted_child_info)

      @dependents << child_event.serialize_dependent_result(
        participant,
        'Child',
        'Other',
        {
          'event_date': formatted_child_info['event_date'],
          'type': event_type
        }
      )
    end

    def report_674
      adult_attending_school = BGS::DependentEvents::AdultChildAttendingSchool.new(
        @dependents_application
      )
      formatted_674_info = adult_attending_school.format_info
      student_address = @dependents_application['student_address_marriage_tuition']['address']
      participant = bgs_service.create_participant(@proc_id)
      bgs_service.create_person(@proc_id, participant[:vnp_ptcpnt_id], formatted_674_info)
      bgs_service.generate_address(@proc_id, participant[:vnp_ptcpnt_id], student_address)

      @dependents << adult_attending_school.serialize_dependent_result(
        participant,
        'Child',
        'Other',
        { 'type': '674' }
      )
    end

    def child_event_type(event_type)
      if event_type == 'child_marriage'
        return BGS::DependentEvents::ChildMarriage.new(@dependents_application['child_marriage'])
      end

      BGS::DependentEvents::ChildStoppedAttendingSchool.new(@dependents_application['child_stopped_attending_school'])
    end

    def bgs_service
      @bgs_service ||= BGS::Service.new(@user)
    end
  end
end
