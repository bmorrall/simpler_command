# frozen_string_literal: true

require "simplecov"

active_support_enabled = ENV["ACTIVE_SUPPORT_ENABLED"] == "1"
SimpleCov.command_name active_support_enabled ? "test:unit:as" : "test:unit"

SimpleCov.start do
  enable_coverage :branch

  add_filter(/spec/)
end

require "bundler/setup"
require "simpler_command"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    if active_support_enabled
      require "active_model"

      require "active_support/core_ext/object/json"
      require "active_support/core_ext/array/conversions"
      require "active_support/core_ext/string/inflections"
    end
  end

  # Add tag :as_only to only run tests when ActiveSupport has been included
  config.before(:each, :as_only) do
    skip "Set ACTIVE_SUPPORT_ENABLED=1 to run" unless active_support_enabled
  end
end
