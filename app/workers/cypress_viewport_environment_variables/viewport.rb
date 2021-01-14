module CypressViewportEnvironmentVariables
  class Viewport
    DEVICES = "" # create device lookup table based on width and height

    attr_reader :number_of_users

    def initialize(start_date:, end_date:, row:, total_users:)
      number_of_users = row.metrics.first.values.first.to_f
      device, resolution = row.dimensions[0], row.dimensions[1]

      @list = "VA Top #{device.capitalize} Viewports"
      @rank = nil
      @devicesWithViewport = DEVICES
      @percentTraffic = "#{calculate_percentage_of_users_who_use_viewport(number_of_users, total_users)}%"
      @percentTrafficPeriod = "from #{start_date} to #{end_date}"
      @viewportPreset = "va-top-#{device}-"
      @width, @height = resolution.split('x')
    end

    private

    def calculate_percentage_of_users_who_use_viewport(number_of_users, total_users)
      (number_of_users / total_users * 100).round(2)
    end
  end
end