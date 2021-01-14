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
      parse_google_analytics_viewport_report_to_create_top_viewport_collections
      update_viewports_with_rank_in_each_top_viewport_collection
    end

    private

    def parse_user_report_for_total_users(user_report)
      user_report.data.totals.first.values.first.to_f
    end

    def parse_google_analytics_viewport_report_to_create_top_viewport_collections
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

        break if all_top_viewport_collections_full?
      end
    end

    def make_new_viewport(row)
      CypressViewportEnvironmentVariables::
        Viewport.new(start_date: start_date,
                     end_date: end_date,
                     row: row,
                     total_users: total_users)
    end

    def all_top_viewport_collections_full?
      viewport_collections.all? do |viewports|
        viewports.count >= NUMBER_OF_TOP_VIEWPORTS
      end
    end

    def update_viewports_with_rank_in_each_top_viewport_collection
      viewport_collections.each do |collection|
        collection.each_with_index do |viewport, index|
          rank = (index + 1).to_s
          viewport.update_attributes_that_reference_rank(rank)
        end
      end
    end

    def viewport_collections
      [top_mobile_viewports, top_tablet_viewports, top_desktop_viewports]
    end
  end
end