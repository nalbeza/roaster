# -*- encoding: utf-8 -*-
require File.expand_path('../lib/roaster/version', __FILE__)
 
Gem::Specification.new do |gem|
  gem.name          = 'roaster'
  gem.authors       = ['Nicolas Albeza']
  gem.email         = ['n.albeza@gmail.com']
  gem.description   = %q{Model/JSONAPI mapping}
  gem.summary       = %q{Expose your models through a JSONAPI API with a simple mapping}
  gem.homepage      = 'https://github.com/pause/roaster'
  gem.license       = 'MIT'
 
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.version       = Roaster::VERSION

  gem.add_runtime_dependency "representable", "~> 2.0.0"

end
