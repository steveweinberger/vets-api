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
  end
end