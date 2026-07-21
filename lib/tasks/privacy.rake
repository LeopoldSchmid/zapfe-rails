namespace :privacy do
  desc "Export subject data as JSON to stdout (EMAIL=...)"
  task export: :environment do
    puts JSON.pretty_generate(Privacy::SubjectData.new(ENV.fetch("EMAIL")).export)
  end

  desc "Show whether an erasure is blocked; never mutates data"
  task check_erasure: :environment do
    subject = Privacy::SubjectData.new(ENV.fetch("EMAIL"))
    puts JSON.pretty_generate(subject.export.transform_values { |value| value.respond_to?(:size) ? value.size : value })
    abort "Active legal hold" if PrivacyLegalHold.for_email(ENV.fetch("EMAIL")).exists?
    abort "Invoice retention applies" if subject.export.fetch(:invoices).any?
  end
end
