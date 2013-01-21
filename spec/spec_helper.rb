require 'cat'
gem 'rspec'
require 'table_print'
require 'ostruct'

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end

