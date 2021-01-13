module CypressViewportEnvironmentVariables
  class ViewportCollection

    NUMBER_OF_TOP_VIEWPORTS = 5
    DEVICES = ""

    attr_reader :start_date, :end_date, :google_analytics_report,
                 :top_mobile_viewports, :top_tablet_viewports, :top_desktop_viewports
    
    def initialize(start_date, end_date, report)
      @top_mobile_viewports = []
      @top_tablet_viewports = []
      @top_desktop_viewports = []
      @start_date = start_date
      @end_date = end_date
      @google_analytics_report = report
      parse_report
    end

    private

    def parse_report
      google_analytics_report.data.rows.each do |row|
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

      {
        list: "VA Top #{device.capitalize} Viewports",
        rank: nil,
        devicesWithViewport: DEVICES, # create device lookup table based on width and height
        percentTraffic: nil, # oops, i forgot to get that from GA!
        percentTrafficPeriod: "#{start_date}--#{end_date}",
        viewportPreset: "va-top-#{device.capitalize}-",
        width: width,
        height: height
      }
    end
  end
end