require "simplecov"
SimpleCov.start

if ENV.key?("CI")
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "bundler/setup"
require "object_path"
require "object_path/mixin"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
