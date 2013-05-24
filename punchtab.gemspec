# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'punchtab/version'

Gem::Specification.new do |s|
  s.name        = 'punchtab'
  s.version     = Punchtab::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Rupak Ganguly']
  s.date        = %q{2013-05-24}
  s.email       = ['rupakg@gmail.com']
  s.homepage    = %q{http://github.com/rupakg/punchtab}
  s.summary     = %q{Ruby wrapper for PunchTab API}
  s.description = %q{Ruby wrapper for PunchTab API. PunchTab is the world's first instant loyalty platform.}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency('json',     '~> 1.7.7')
  s.add_runtime_dependency('hashie',   '~> 2.0')
  s.add_runtime_dependency('httparty', '~> 0.11')

  #s.add_development_dependency(%q<shoulda>, ['>= 2.10.1'])
  #s.add_development_dependency(%q<jnunemaker-matchy>, ['= 0.4.0'])
  #s.add_development_dependency(%q<mocha>, ['~> 0.9.12'])
  #s.add_development_dependency(%q<fakeweb>, ['~> 1.3.0'])

end
