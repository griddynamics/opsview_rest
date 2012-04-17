require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "opsview_rest"
  gem.version = OpsviewRest::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.authors = ["Christian Paredes"]
  gem.email = ["christian.paredes@seattlebiomed.org"]
  gem.homepage = "http://github.com/cparedes/opsview_rest"
  gem.description   = %Q{Opsview REST API library}
  gem.summary = %Q{Opsview REST API library}
  gem.files = Dir.glob('lib/**/*.rb')
  gem.require_paths = ["lib"]
  gem.add_dependency('json')
  gem.add_dependency('rest-client')
  gem.add_development_dependency('rspec')
end

