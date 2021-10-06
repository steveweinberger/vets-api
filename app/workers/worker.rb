# frozen_string_literal: true

module MeasureRunTime
  def measure_run_time
    starting = Time.now
    yield
    StatsD.measure "shared.sidekiq.#{self.class}.runtime", Time.now - starting
  end
end
