#!/usr/bin/env rake

require 'rubygems'
require 'rake'

begin
  require 'rspec/core/rake_task'

  desc 'Default: run specs'
  task :default => :spec

  desc "Run specs"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  $stderr.puts "RSpec not available. Install it with: gem install rspec-core rspec-expectations"
end