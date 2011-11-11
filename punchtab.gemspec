# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "punchtab/version"

Gem::Specification.new do |s|
  s.name        = "punchtab"
  s.version     = Punchtab::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rupak Ganguly"]
  s.date        = %q{2011-11-11}
  s.email       = ["rupakg@gmail.com"]
  s.homepage    = %q{http://github.com/rupakg/ruby-punchtab}
  s.summary     = %q{Ruby wrapper for PunchTab API}
  s.description = %q{Ruby wrapper for PunchTab API. PunchTab is the world's first instant loyalty platform.}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
