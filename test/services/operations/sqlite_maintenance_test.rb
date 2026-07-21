require "test_helper"

class Operations::SqliteMaintenanceTest < ActiveSupport::TestCase
  setup do
    @directory = Pathname(Dir.mktmpdir("sqlite-maintenance"))
    @path = @directory.join("test.sqlite3")
    database = SQLite3::Database.new(@path.to_s)
    database.execute("PRAGMA journal_mode=WAL")
    database.execute("CREATE TABLE examples (value TEXT)")
    database.execute("INSERT INTO examples VALUES ('ok')")
    database.close
  end

  teardown { FileUtils.remove_entry(@directory) }

  test "checks integrity and reports capacity signals" do
    result = Operations::SqliteMaintenance.new(paths: [ @path ], min_free_bytes: 0).check.fetch(@path)

    assert_equal "ok", result.fetch(:integrity)
    assert_operator result.fetch(:page_count), :>, 0
    assert result.key?(:freelist_count)
  end

  test "checkpoints and vacuums only when capacity permits" do
    maintenance = Operations::SqliteMaintenance.new(paths: [ @path ], min_free_bytes: 0)

    assert maintenance.checkpoint!.fetch(@path)
    assert_equal "ok", maintenance.vacuum!.fetch(@path).fetch(:integrity)
  end

  test "refuses mutation when the disk capacity threshold is not met" do
    maintenance = Operations::SqliteMaintenance.new(paths: [ @path ], min_free_bytes: 1.petabyte)

    assert_raises(RuntimeError) { maintenance.vacuum! }
  end
end
