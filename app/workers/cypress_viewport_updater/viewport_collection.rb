require_relative './viewport'

module CypressViewportUpdater
  class ViewportCollection

    NUMBER_OF_TOP_VIEWPORTS = 5

    attr_reader :start_date, :end_date, :total_users, :viewports
    
    def initialize(start_date:, end_date:, user_report:, viewport_report:)
      @start_date = start_date
      @end_date = end_date
      @total_users = parse_user_report_for_total_users(user_report)
      @viewports = { mobile: [], tablet: [], desktop: [] }
      parse_viewport_report_to_populate_viewports(viewport_report)
      update_viewport_attributes_that_reference_rank
    end

    private

    def parse_user_report_for_total_users(user_report)
      user_report.data.totals.first.values.first.to_f
    end

    def parse_viewport_report_to_populate_viewports(viewport_report)
      viewport_report.data.rows.each do |row|
        device = row.dimensions.first

        case device
        when 'mobile'
          mobile_viewports = viewports[:mobile]
          if mobile_viewports.size < NUMBER_OF_TOP_VIEWPORTS &&
               width_and_height_set?(row)
            mobile_viewports << make_viewport(row)
          end
        when 'tablet'
          tablet_viewports = viewports[:tablet]
          if tablet_viewports.size < NUMBER_OF_TOP_VIEWPORTS &&
               width_and_height_set?(row)
            tablet_viewports << make_viewport(row)
          end
        when 'desktop'
          desktop_viewports = viewports[:desktop]
          if desktop_viewports.size < NUMBER_OF_TOP_VIEWPORTS &&
               width_and_height_set?(row)
            desktop_viewports << make_viewport(row)
          end
        end

        break if viewports_full?
      end
    end

    def width_and_height_set?(row)
      row.dimensions[1] != "(not set)"
    end

    def make_viewport(row)
      CypressViewportUpdater::
        Viewport.new(start_date: start_date,
                     end_date: end_date,
                     row: row,
                     total_users: total_users)
    end

    def viewports_full?
      viewport_types.all? do |viewports|
        viewports.count >= NUMBER_OF_TOP_VIEWPORTS
      end
    end

    def update_viewport_attributes_that_reference_rank
      viewport_types.each do |viewports|
        viewports.each_with_index do |viewport, index|
          rank = (index + 1).to_s
          viewport.update_attributes_that_reference_rank(rank)
        end
      end
    end

    def viewport_types
      [viewports[:mobile], viewports[:tablet], viewports[:desktop]]
    end
  end
end