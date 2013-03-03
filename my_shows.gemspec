# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'my_shows/version'

Gem::Specification.new do |gem|
  gem.name          = "my_shows"
  gem.version       = MyShows::VERSION
  gem.authors       = ["Paul Nikitochkin"]
  gem.email         = ["pftg@jetthoughts.com"]
  gem.description   = %q{My Shows get list of next episodes from Sidereel.com, find torrent links and enque them to download}
  gem.summary       = %q{New TV Show Episodes downloader}
  gem.homepage      = "http://github.com/pftg/my_shows"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.executables = %w(my_shows)
  gem.default_executable = 'my_shows'
  gem.add_dependency('hashie', '~> 1.2.0')
  gem.add_dependency('faraday_middleware', '~> 0.9.0')
  gem.add_dependency('fuzzy-string-match', '~> 0.9.4')
  gem.add_dependency('netrc', '~> 0.7.7')
  gem.add_dependency('nokogiri')
  gem.add_dependency('colorize')
  gem.add_dependency('launchy')
end
