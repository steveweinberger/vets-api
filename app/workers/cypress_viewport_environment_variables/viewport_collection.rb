module CypressViewportEnvironmentVariables
  class ViewportCollection

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
          if top_mobile_viewports.size < 5
            top_mobile_viewports << create_viewport_hash(row)
          end
        when 'tablet'
          if top_tablet_viewports.size < 5
            top_tablet_viewports << create_viewport_hash(row)
          end
        when 'desktop'
          if top_desktop_viewports.size < 5
            top_desktop_viewports << create_viewport_hash(row)
          end
        end

        break if [top_mobile_viewports,
                  top_tablet_viewports,
                  top_desktop_viewports].all? { |array| array.size >= 5 }
      end
    end
  end
end