# -*- encoding: utf-8 -*-
require File.expand_path('../lib/url2yml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chuck"]
  gem.email         = ["colczak@yahoo.com"]
  gem.description   = %q{Generates a yml definition from an url, usually for config from the env}
  gem.summary       = %q{Generates a yml definition from an url, usually for config from the env}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "url2yml"
  gem.require_paths = ["lib"]
  gem.version       = Url2yml::VERSION
end
