#!/usr/bin/env rake

require 'rubygems'
require 'rake'

begin
  require 'rspec/core/rake_task'

  desc 'Default: run specs'
  task :default => :rspec

  desc "Run rspecs"
  RSpec::Core::RakeTask.new(:rspec)

  #RSpec::Core::RakeTask.new(:rspec) do |t|
  #  t.rspec_opts = ["-c", "-f progress -f html --out reports/rspec_report.html"]
  #  t.pattern ='**/tests/**/*_spec.rb'
  #end
rescue LoadError
  $stderr.puts "RSpec not available. Install it with: gem install rspec-core rspec-expectations"
end