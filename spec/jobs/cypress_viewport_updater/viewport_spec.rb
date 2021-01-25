# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::Viewport do
  before do
    VCR.use_cassette('cypress_viewport_updater/google_analytics_after_request_report') do
      ga = CypressViewportUpdater::GoogleAnalyticsReports
           .new
           .request_reports
      total_users = ga.user_report.data.totals.first.values.first.to_f
      row = ga.viewport_report.data.rows.first
      @viewport = described_class.new(row: row, rank: 1, total_users: total_users)
    end
  end

  describe '#new' do
    it 'returns a new instance' do
      expect(@viewport).to be_an_instance_of(described_class)
    end
  end

  describe '#viewportPreset' do
    it 'returns the correct value' do
      expect(@viewport.viewportPreset).to eq('va-top-desktop-1')
    end
  end

  describe '#rank' do
    it 'returns the correct value' do
      expect(@viewport.rank).to eq(1)
    end    
  end

  describe '#width' do
    it 'returns the correct value' do
      expect(@viewport.width).to eq(1280)
    end    
  end

  describe '#height' do
    it 'returns the correct value' do
      expect(@viewport.height).to eq(960)
    end    
  end
end
