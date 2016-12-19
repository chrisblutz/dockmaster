require 'simplecov'
SimpleCov.start

require 'dockmaster'

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    Dockmaster::CONFIG[:output] = 'rspec/tests/files'
  end

  config.after(:each) do
    FileUtils.rm_rf('rspec')
  end
end
