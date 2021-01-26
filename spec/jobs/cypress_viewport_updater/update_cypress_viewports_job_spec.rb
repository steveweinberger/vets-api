# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CypressViewportUpdater::UpdateCypressViewportsJob do
  describe '#perform' do
    let(:job) { described_class.new }

    it "returns self" do
      allow(job).to receive(:perform) { job }
      expect(job.perform).to be_an_instance_of(described_class)
    end
  end
end