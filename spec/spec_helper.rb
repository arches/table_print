require 'cat'
require 'table_print'
require 'ostruct'

RSpec.configure do |config|
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end
