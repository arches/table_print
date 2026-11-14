require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'rdoc/task'

require_relative 'lib/table_print/version'

desc 'Default: run specs and cucumber features.'
task :default => [:spec, :cucumber]

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run cucumber features'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['features']
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "table_print #{TablePrint::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
