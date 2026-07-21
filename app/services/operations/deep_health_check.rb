module Operations
  class DeepHealthCheck
    CHECKS = %i[database_write queue_database cache storage mail_render].freeze

    def initialize(storage_service: ActiveStorage::Blob.service, cache: Rails.cache)
      @storage_service = storage_service
      @cache = cache
    end

    def call
      results = CHECKS.index_with { |name| check(name) { send("check_#{name}") } }
      { status: results.values.all? { |result| result[:status] == "ok" } ? "ok" : "error", checks: results }
    end

    private

    def check(_name)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      { status: "ok", duration_ms: elapsed_ms(started) }
    rescue StandardError => error
      {
        status: "error",
        duration_ms: elapsed_ms(started),
        error_class: error.class.name,
        error_digest: Digest::SHA256.hexdigest(error.message.to_s)
      }
    end

    def check_database_write
      probe = OperationalProbe.create!(nonce: SecureRandom.uuid)
      probe.destroy!
    end

    def check_queue_database
      return ApplicationRecord.connection.select_value("SELECT 1") unless defined?(SolidQueue::Record)

      SolidQueue::Record.connection.select_value("SELECT 1")
    end

    def check_cache
      key = "deep-health/#{SecureRandom.uuid}"
      @cache.write(key, "ok", expires_in: 1.minute)
      raise "cache read mismatch" unless @cache.read(key) == "ok"
    ensure
      @cache.delete(key) if key
    end

    def check_storage
      key = "deep-health/#{SecureRandom.uuid}"
      @storage_service.upload(key, StringIO.new("ok"))
      raise "storage read mismatch" unless @storage_service.download(key) == "ok"
    ensure
      @storage_service.delete(key) if key
    end

    def check_mail_render
      inquiry = Inquiry.new(
        source: "contact", first_name: "Monitoring", last_name: "Check",
        email: "monitoring@example.invalid", privacy_accepted: true
      )
      raise inquiry.errors.full_messages.to_sentence unless inquiry.valid?

      InquiryMailer.customer_confirmation(inquiry).message.encoded
      InquiryMailer.admin_notification(inquiry).message.encoded
    end

    def elapsed_ms(started)
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round(1)
    end
  end
end
