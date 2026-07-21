Rails.application.config.permissions_policy do |policy|
  policy.camera :none
  policy.geolocation :none
  policy.gyroscope :none
  policy.magnetometer :none
  policy.microphone :none
  policy.payment :none
  policy.usb :none
end
