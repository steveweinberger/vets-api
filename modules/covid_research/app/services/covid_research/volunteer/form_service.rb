# frozen_string_literal: true

require 'json_schemer'
require 'vets_json_schema'

module CovidResearch
  module Volunteer
    class FormService
      SCHEMA = 'COVID-VACCINE-TRIAL'
      # TODO pass in correct vets-json-schema name for intake vs update

      attr_reader :worker

      delegate :valid?, to: :schema

      def initialize(schema_name = SCHEMA, worker = GenisisDeliveryJob)
        @worker = worker
        @schema_name = schema_name
        puts "in initialize"
        @schema = dev_schema
        puts @schema
        puts "end of init"
      end

      def valid!(json)
        # puts "Check if JSON is valid"
        # puts json
        raise SchemaValidationError, submission_errors(json) unless valid?(json)

        valid?(json)
      end

      def submission_errors(json)
        schema.validate(json).map do |e|
          if e['data_pointer'].blank?
            {
              detail: e['details']
            }
          else
            {
              source: {
                pointer: e['data_pointer']
              }
            }
          end
        end
      end

      def queue_delivery(submission)
        redis_format = RedisFormat.new
        redis_format.form_data = JSON.generate(submission)        
        worker.perform_async(redis_format.to_json)
      end

      private

      def schema
        @schema ||= JSONSchemer.schema(schema_data)
      end

      def schema_data
        VetsJsonSchema::SCHEMAS[SCHEMA]
      end

      class SchemaValidationError < StandardError
        attr_reader :errors

        def initialize(errors)
          @errors = errors
        end
      end

      def dev_schema
        puts "In Dev Schema"
        puts @schema_name
        file = File.read("./modules/covid_research/app/services/covid_research/volunteer/temp-#{@schema_name}.json")
        JSONSchemer.schema(file)
      end

    end
  end
end
