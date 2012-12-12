# -*- encoding: utf-8 -*-
require File.expand_path('../lib/retry-handler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["kimoto"]
  gem.email         = ["sub+peerler@gmail.com"]
  gem.description   = %q{Easy retry handling}
  gem.summary       = %q{Easy retry handling}
  gem.homepage      = "https://github.com/kimoto/retry-handler"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "retry-handler"
  gem.require_paths = ["lib"]
  gem.version       = Retry::Handler::VERSION

  gem.add_development_dependency "rspec"
end
