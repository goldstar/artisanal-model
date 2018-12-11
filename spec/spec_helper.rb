require "rubygems"
require "bundler"
require "pry"
require "rspec/its"
require "dry-types"

require "bundler/setup"
require "artisanal-model"

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
  config.order = :random
end
