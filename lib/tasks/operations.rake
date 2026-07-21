namespace :operations do
  desc "Check every production SQLite database without changing it"
  task sqlite_check: :environment do
    puts JSON.pretty_generate(Operations::SqliteMaintenance.new.check)
  end

  desc "Checkpoint every production SQLite WAL (requires CONFIRM_SQLITE_MAINTENANCE=1)"
  task sqlite_checkpoint: :environment do
    abort "Set CONFIRM_SQLITE_MAINTENANCE=1" unless ENV["CONFIRM_SQLITE_MAINTENANCE"] == "1"

    puts JSON.pretty_generate(Operations::SqliteMaintenance.new.checkpoint!)
  end

  desc "VACUUM every production SQLite DB (maintenance window and confirmation required)"
  task sqlite_vacuum: :environment do
    abort "Set CONFIRM_SQLITE_MAINTENANCE=1" unless ENV["CONFIRM_SQLITE_MAINTENANCE"] == "1"

    puts JSON.pretty_generate(Operations::SqliteMaintenance.new.vacuum!)
  end
end
