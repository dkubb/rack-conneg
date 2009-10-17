begin
  require 'yardstick/rake/measurement'
  require 'yardstick/rake/verify'

  # yardstick_measure task
  Yardstick::Rake::Measurement.new

  # verify_measurements task
  Yardstick::Rake::Verify.new do |verify|
    verify.threshold = 100
  end
rescue LoadError
  # do nothing
end
