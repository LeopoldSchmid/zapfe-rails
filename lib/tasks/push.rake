namespace :push do
  desc "Print a new VAPID key pair for Web Push configuration"
  task vapid_keys: :environment do
    key = Webpush.generate_key
    puts "VAPID_PUBLIC_KEY=#{key.public_key}"
    puts "VAPID_PRIVATE_KEY=#{key.private_key}"
    puts "VAPID_SUBJECT=mailto:info@zapfe.jetzt"
  end
end
