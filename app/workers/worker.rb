# frozen_string_literal: true

module MeasureRunTime
  def measure_run_time
    starting = Time.now
    yield
    StatsD.measure "", Time.now - starting
  end
end
