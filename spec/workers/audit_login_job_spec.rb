# frozen_string_literal: true

describe AuditLoginJob do
  describe '#perform' do
    expect_any_instance_of(AuditLogJob)to receive(:transform_form).and_return({})
  end
end
