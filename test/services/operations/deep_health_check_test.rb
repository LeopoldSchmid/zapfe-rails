require "test_helper"

class Operations::DeepHealthCheckTest < ActiveSupport::TestCase
  class FailingStorage
    def upload(*) = raise(IOError, "synthetic secret storage path")
    def download(*) = nil
    def delete(*) = true
  end

  test "reports a dependency failure without exposing its message" do
    result = Operations::DeepHealthCheck.new(storage_service: FailingStorage.new).call
    storage = result.dig(:checks, :storage)

    assert_equal "error", result.fetch(:status)
    assert_equal "error", storage.fetch(:status)
    assert_equal "IOError", storage.fetch(:error_class)
    assert_predicate storage.fetch(:error_digest), :present?
    assert_not_includes result.to_json, "secret storage path"
  end
end
