module CypressViewportEnvironmentVariables
  class ViewportCollection

    NUMBER_OF_TOP_VIEWPORTS = 5

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
            top_mobile_viewports << create_viewport_hash(row)
          end
        when 'tablet'
          if top_tablet_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_tablet_viewports << create_viewport_hash(row)
          end
        when 'desktop'
          if top_desktop_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_desktop_viewports << create_viewport_hash(row)
          end
        end

        break if [top_mobile_viewports,
                  top_tablet_viewports,
                  top_desktop_viewports].all? do |array|
                    array.size >= NUMBER_OF_TOP_VIEWPORTS
                  end
      end
    end

    def create_viewport_hash(row)
      dimensions = row.dimensions
      device, resolution = dimensions[0], dimensions[1]
      width, height = resolution.split('x')

      # exmple viewport object:
      # {
      #   "list": "VA Top Mobile Viewports",
      #   "rank": 2,
      #   "devicesWithViewport": "iPhone X, iPhone XS, iPhone 11 Pro",
      #   "percentTraffic": 4.11,
      #   "percentTrafficPeriod": "December, 2020",
      #   "viewportPreset": "va-top-mobile-2",
      #   "width": 375,
      #   "height": 812
      # }

      {
        width: width
        height: height
      }
    end
  end
end