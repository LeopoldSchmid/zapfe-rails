require "open3"

module Operations
  class SqliteMaintenance
    MIN_FREE_BYTES = 1.gigabyte

    def initialize(paths: production_database_paths, min_free_bytes: MIN_FREE_BYTES)
      @paths = Array(paths).map { |path| Pathname(path) }
      @min_free_bytes = min_free_bytes
    end

    def check
      @paths.index_with { |path| inspect_database(path) }
    end

    def checkpoint!
      ensure_capacity!
      @paths.index_with do |path|
        with_database(path) { |db| db.execute("PRAGMA wal_checkpoint(TRUNCATE)").first }
      end
    end

    def vacuum!
      ensure_capacity!
      @paths.each { |path| with_database(path) { |db| db.execute("VACUUM") } }
      check
    end

    private

    def inspect_database(path)
      with_database(path) do |db|
        integrity = db.get_first_value("PRAGMA integrity_check")
        raise "SQLite integrity check failed for #{path.basename}" unless integrity == "ok"

        {
          integrity: integrity,
          page_count: db.get_first_value("PRAGMA page_count"),
          freelist_count: db.get_first_value("PRAGMA freelist_count"),
          journal_mode: db.get_first_value("PRAGMA journal_mode")
        }
      end
    end

    def with_database(path)
      raise Errno::ENOENT, path unless path.file?

      database = SQLite3::Database.new(path.to_s)
      database.busy_timeout = 5_000
      yield database
    ensure
      database&.close
    end

    def ensure_capacity!
      @paths.each do |path|
        output, status = Open3.capture2("df", "-Pk", path.dirname.to_s)
        raise "Could not determine free disk space" unless status.success?

        free_bytes = Integer(output.lines.last.split.fetch(3)) * 1024
        required = [ @min_free_bytes, path.size * 2 ].max
        raise "Insufficient free space for SQLite maintenance" if free_bytes < required
      end
    end

    def production_database_paths
      Rails.application.config.database_configuration.fetch("production").values.map do |configuration|
        Rails.root.join(configuration.fetch("database"))
      end.uniq
    end
  end
end
