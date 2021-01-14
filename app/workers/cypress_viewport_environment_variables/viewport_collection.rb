module CypressViewportEnvironmentVariables
  class ViewportCollection

    NUMBER_OF_TOP_VIEWPORTS = 5
    DEVICES = "" # create device lookup table based on width and height

    attr_reader :start_date, :end_date, :total_users,
                :google_analytics_viewport_report, :top_mobile_viewports,
                :top_tablet_viewports, :top_desktop_viewports
    
    def initialize(start_date:, end_date:, user_report:, viewport_report:)
      @top_mobile_viewports = []
      @top_tablet_viewports = []
      @top_desktop_viewports = []
      @start_date = start_date
      @end_date = end_date
      @total_users = parse_user_report_for_total_users(user_report)
      @google_analytics_viewport_report = viewport_report
      parse_viewport_report
    end

    private

    def parse_user_report_for_total_users(user_report)
      user_report.data.totals.first.values.first.to_f
    end

    def parse_viewport_report
      google_analytics_viewport_report.data.rows.each do |row|
        device = row.dimensions.first

        case device
        when 'mobile'
          if top_mobile_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_mobile_viewports << create_viewport(row)
          end
        when 'tablet'
          if top_tablet_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_tablet_viewports << create_viewport(row)
          end
        when 'desktop'
          if top_desktop_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_desktop_viewports << create_viewport(row)
          end
        end

        break if [top_mobile_viewports,
                  top_tablet_viewports,
                  top_desktop_viewports].all? do |array|
                    array.size >= NUMBER_OF_TOP_VIEWPORTS
                  end
      end
    end

    def create_viewport(row)
      dimensions = row.dimensions
      device, resolution = dimensions[0], dimensions[1]
      width, height = resolution.split('x')
      number_of_users = row.metrics.first.values.first.to_f

      {
        list: "VA Top #{device.capitalize} Viewports",
        rank: nil,
        devicesWithViewport: DEVICES,
        percentTraffic: "#{calculate_percentage_of_users_who_use_viewport(number_of_users)}%",
        percentTrafficPeriod: "from #{start_date} to #{end_date}",
        viewportPreset: "va-top-#{device}-",
        width: width,
        height: height
      }
    end

    def calculate_percentage_of_users_who_use_viewport(number_of_users)
      (number_of_users / total_users * 100).round(2)
    end
  end
end