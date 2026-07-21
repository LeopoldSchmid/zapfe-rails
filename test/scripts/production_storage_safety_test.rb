require "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

class ProductionStorageSafetyTest < ActiveSupport::TestCase
  BACKUP_SCRIPT = Rails.root.join("script/backup_storage").to_s
  OFFSITE_UPLOAD_SCRIPT = Rails.root.join("script/upload_offsite_backup").to_s
  OFFSITE_RUNNER_SCRIPT = Rails.root.join("script/run_offsite_backup").to_s
  RESTORE_SCRIPT = Rails.root.join("script/restore_storage").to_s
  REPLACE_SCRIPT = Rails.root.join("script/replace_prod_storage_from_staging").to_s

  test "backup and restore preserve a consistent SQLite snapshot and files" do
    Dir.mktmpdir("storage-safety") do |root|
      source = File.join(root, "source")
      archive = File.join(root, "backup.tar.gz")
      target = File.join(root, "restored")
      FileUtils.mkdir_p(File.join(source, "uploads"))
      File.write(File.join(source, "uploads", "invoice.pdf"), "document-v1")
      create_database(File.join(source, "production.sqlite3"), "before-backup")

      stdout, stderr, status = run_script(BACKUP_SCRIPT, "--source", source, "--output", archive, "--allow-plaintext")
      assert status.success?, [ stdout, stderr ].join("\n")
      assert File.exist?(archive)

      create_database(File.join(source, "production.sqlite3"), "after-backup")
      File.write(File.join(source, "uploads", "invoice.pdf"), "document-v2")

      stdout, stderr, status = run_script(RESTORE_SCRIPT, "--archive", archive, "--target", target)
      assert status.success?, [ stdout, stderr ].join("\n")
      assert_equal "before-backup", database_value(File.join(target, "production.sqlite3"))
      assert_equal "document-v1", File.read(File.join(target, "uploads", "invoice.pdf"))
    end
  end

  test "restore rejects a corrupted archive without writing target data" do
    Dir.mktmpdir("storage-corruption") do |root|
      source = File.join(root, "source")
      archive = File.join(root, "backup.tar.gz")
      target = File.join(root, "restored")
      FileUtils.mkdir_p(source)
      create_database(File.join(source, "production.sqlite3"), "safe")
      _stdout, stderr, status = run_script(BACKUP_SCRIPT, "--source", source, "--output", archive, "--allow-plaintext")
      assert status.success?, stderr

      File.open(archive, "r+b") do |file|
        file.seek(-12, IO::SEEK_END)
        file.write("corrupt-data")
      end

      _stdout, _stderr, status = run_script(RESTORE_SCRIPT, "--archive", archive, "--target", target)
      refute status.success?
      assert !Dir.exist?(target) || Dir.empty?(target)
    end
  end

  test "restore never overwrites a non-empty target" do
    Dir.mktmpdir("storage-overwrite") do |root|
      archive = File.join(root, "not-read.tar.gz")
      target = File.join(root, "target")
      FileUtils.mkdir_p(target)
      File.write(File.join(target, "keep.txt"), "keep")
      File.write(archive, "invalid")

      _stdout, stderr, status = run_script(RESTORE_SCRIPT, "--archive", archive, "--target", target)
      refute status.success?
      assert_match(/target must be empty/, stderr)
      assert_equal "keep", File.read(File.join(target, "keep.txt"))
    end
  end

  test "legacy production replacement is fail closed before any remote command" do
    _stdout, stderr, status = run_script(REPLACE_SCRIPT)

    assert_equal 64, status.exitstatus
    assert_match(/intentionally disabled/, stderr)
    assert_match(/restore_storage/, stderr)
  end

  test "offsite upload accepts only encrypted archives and verifies the remote checksum" do
    Dir.mktmpdir("offsite-upload") do |root|
      archive = File.join(root, "backup.tar.gz.age")
      plaintext = File.join(root, "backup.tar.gz")
      key = File.join(root, "backup-key")
      known_hosts = File.join(root, "known_hosts")
      fake_bin = File.join(root, "bin")
      uploaded = File.join(root, "uploaded")
      File.write(archive, "encrypted-backup")
      File.write(plaintext, "plaintext-backup")
      File.write(key, "private-key")
      File.chmod(0o600, key)
      File.write(known_hosts, "storage-box ssh-ed25519 test-key\n")
      FileUtils.mkdir_p(fake_bin)
      File.write(File.join(fake_bin, "ssh"), fake_ssh)
      File.write(File.join(fake_bin, "scp"), fake_scp)
      FileUtils.chmod("+x", [ File.join(fake_bin, "ssh"), File.join(fake_bin, "scp") ])

      common = [ "--host", "u635934.your-storagebox.de", "--user", "u635934", "--ssh-key", key, "--known-hosts", known_hosts, "--remote-path", "zapfe/backup.tar.gz.age" ]
      environment = {
        "PATH" => "#{fake_bin}:#{ENV.fetch('PATH')}",
        "FAKE_UPLOAD_DIR" => uploaded,
        "FAKE_REMOTE_EXISTS" => "0",
        "FAKE_REMOTE_SHA256" => Digest::SHA256.file(archive).hexdigest
      }

      _stdout, stderr, status = run_script_with(environment, OFFSITE_UPLOAD_SCRIPT, "--archive", plaintext, *common)
      refute status.success?
      assert_match(/not encrypted with age/, stderr)

      stdout, stderr, status = run_script_with(environment, OFFSITE_UPLOAD_SCRIPT, "--archive", archive, *common)
      assert status.success?, [ stdout, stderr ].join("\n")
      assert_equal "encrypted-backup", File.read(File.join(uploaded, "backup.tar.gz.age"))
      assert_match(/Offsite upload verified/, stdout)
    end
  end

  test "offsite upload refuses existing remote targets before copying" do
    Dir.mktmpdir("offsite-existing") do |root|
      archive = File.join(root, "backup.tar.gz.age")
      key = File.join(root, "backup-key")
      known_hosts = File.join(root, "known_hosts")
      fake_bin = File.join(root, "bin")
      File.write(archive, "encrypted-backup")
      File.write(key, "private-key")
      File.chmod(0o600, key)
      File.write(known_hosts, "storage-box ssh-ed25519 test-key\n")
      FileUtils.mkdir_p(fake_bin)
      File.write(File.join(fake_bin, "ssh"), fake_ssh)
      File.write(File.join(fake_bin, "scp"), fake_scp)
      FileUtils.chmod("+x", [ File.join(fake_bin, "ssh"), File.join(fake_bin, "scp") ])

      environment = {
        "PATH" => "#{fake_bin}:#{ENV.fetch('PATH')}",
        "FAKE_UPLOAD_DIR" => File.join(root, "uploaded"),
        "FAKE_REMOTE_EXISTS" => "1"
      }
      _stdout, stderr, status = run_script_with(environment, OFFSITE_UPLOAD_SCRIPT,
        "--archive", archive, "--host", "u635934.your-storagebox.de", "--user", "u635934",
        "--ssh-key", key, "--known-hosts", known_hosts, "--remote-path", "zapfe/backup.tar.gz.age")

      refute status.success?
      assert_match(/remote target already exists/, stderr)
      refute Dir.exist?(environment.fetch("FAKE_UPLOAD_DIR"))
    end
  end

  test "offsite runner creates a timestamped encrypted archive and delegates a safe remote path" do
    Dir.mktmpdir("offsite-runner") do |root|
      source = File.join(root, "source")
      archive_dir = File.join(root, "archives")
      key = File.join(root, "backup-key")
      known_hosts = File.join(root, "known_hosts")
      calls = File.join(root, "calls")
      backup = File.join(root, "fake-backup")
      upload = File.join(root, "fake-upload")
      FileUtils.mkdir_p(source)
      File.write(key, "private-key")
      File.chmod(0o600, key)
      File.write(known_hosts, "storage-box ssh-ed25519 test-key\n")
      File.write(backup, fake_backup)
      File.write(upload, fake_upload)
      FileUtils.chmod("+x", [ backup, upload ])

      stdout, stderr, status = run_script_with({ "ZAPFE_BACKUP_SCRIPT" => backup, "ZAPFE_UPLOAD_SCRIPT" => upload, "FAKE_CALLS" => calls }, OFFSITE_RUNNER_SCRIPT,
        "--source", source, "--archive-dir", archive_dir,
        "--age-recipient", "age1example", "--storage-host", "u635934-sub1.your-storagebox.de", "--storage-user", "u635934-sub1",
        "--ssh-key", key, "--known-hosts", known_hosts, "--remote-prefix", "zapfe")

      assert status.success?, [ stdout, stderr ].join("\n")
      archive = Dir.glob(File.join(archive_dir, "*.age")).sole
      assert_match(/zapfe-storage-\d{4}-\d{2}-\d{2}T\d{6}Z\.tar\.gz\.age\z/, archive)
      assert_equal "encrypted", File.read(archive)
      assert_includes File.read(calls), "--remote-path zapfe/"
      assert_match(/Offsite backup complete/, stdout)
    end
  end

  private

  def create_database(path, value)
    FileUtils.rm_f(path)
    _stdout, stderr, status = Open3.capture3("sqlite3", path, "CREATE TABLE state(value TEXT); INSERT INTO state VALUES('#{value}');")
    assert status.success?, stderr
  end

  def database_value(path)
    stdout, stderr, status = Open3.capture3("sqlite3", path, "SELECT value FROM state;")
    assert status.success?, stderr
    stdout.strip
  end

  def run_script(script, *arguments)
    Open3.capture3("bash", script, *arguments)
  end

  def run_script_with(environment, script, *arguments)
    Open3.capture3(environment, "bash", script, *arguments)
  end

  def fake_ssh
    <<~'SH'
      #!/usr/bin/env bash
      set -euo pipefail
      command="${*: -1}"
      case "$command" in
        "stat "*)
          [[ "${FAKE_REMOTE_EXISTS:-0}" == "1" ]]
          ;;
        "mkdir -p "*)
          exit 0
          ;;
        "sha256sum "*)
          printf '%s  remote-file\n' "${FAKE_REMOTE_SHA256:?}"
          ;;
        *)
          exit 64
          ;;
      esac
    SH
  end

  def fake_scp
    <<~'SH'
      #!/usr/bin/env bash
      set -euo pipefail
      source="${@: -2:1}"
      destination="${@: -1}"
      mkdir -p "${FAKE_UPLOAD_DIR:?}"
      cp "$source" "${FAKE_UPLOAD_DIR}/$(basename "${destination#*:}")"
    SH
  end

  def fake_backup
    <<~'SH'
      #!/usr/bin/env bash
      set -euo pipefail
      output=""
      while (($#)); do
        case "$1" in
          --output) output="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      printf encrypted > "$output"
    SH
  end

  def fake_upload
    <<~'SH'
      #!/usr/bin/env bash
      set -euo pipefail
      printf '%s\n' "$*" >> "${FAKE_CALLS:?}"
    SH
  end
end
