require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc 'Default: run specs and cucumber features.'
task :default => [:spec, :cucumber]

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run cucumber features'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ['features', '--publish-quiet', '--tags', "'not @todo'"]
end
