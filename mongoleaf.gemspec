# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoleaf/version'

Gem::Specification.new do |gem|
  gem.name          = "mongoleaf"
  gem.version       = Mongoleaf::VERSION
  gem.authors       = ["zeroed"]
  gem.email         = ["foo@bar.org"]
  gem.description   = %q{Yet Another Simple Gem for MongoLab} 
  gem.summary       = %q{Yet Another Simple Gem for MongoLab}
  gem.homepage      = "https://github.com/zeroed/mongoleaf"

  gem.add_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
