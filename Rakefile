require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rspec/core/rake_task'

desc 'Default: run specs and cucumber features.'
if RUBY_VERSION < '1.9'
  task :default => [:spec, :cucumber_187]
else
  task :default => [:spec, :cucumber]
end

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
end

require "cucumber/rake/task"
desc 'Run cucumber features'
Cucumber::Rake::Task.new(:cucumber) do |task|
  task.cucumber_opts = ["features"]
end

desc 'Run cucumber features for ruby 1.8.7'
Cucumber::Rake::Task.new(:cucumber_187) do |task|
  task.cucumber_opts = ["-t", "~@ruby19", "features"]
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rake/rdoctask' # deprecated in Ruby 1.9.3 but needed for Ruby 1.8.7 and JRuby
end
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "table_print #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
