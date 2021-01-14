require_relative './viewport'

module CypressViewportEnvironmentVariables
  class ViewportCollection

    NUMBER_OF_TOP_VIEWPORTS = 5

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
            top_mobile_viewports << make_new_viewport(row)
          end
        when 'tablet'
          if top_tablet_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_tablet_viewports << make_new_viewport(row)
          end
        when 'desktop'
          if top_desktop_viewports.size < NUMBER_OF_TOP_VIEWPORTS
            top_desktop_viewports << make_new_viewport(row)
          end
        end

        break if [top_mobile_viewports,
                  top_tablet_viewports,
                  top_desktop_viewports].all? do |array|
                    array.size >= NUMBER_OF_TOP_VIEWPORTS
                  end
      end
    end

    def make_new_viewport(row)
      CypressViewportEnvironmentVariables::
        Viewport.new(start_date: start_date,
                     end_date: end_date,
                     row: row,
                     total_users: total_users)
    end
  end
end