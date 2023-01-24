# frozen_string_literal: true

lib = ::File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tcr/version'

::Gem::Specification.new do |gem|
  gem.name          = 'tcr_revived'
  gem.version       = ::TCR::VERSION
  gem.authors       = ['Rob Forman', 'Mateusz Drewniak']
  gem.email         = ['rob@robforman.com', 'matmg24@gmail.com']
  gem.description   = 'TCR is a lightweight VCR for TCP sockets.'
  gem.summary       = 'TCR is a lightweight VCR for TCP sockets.'
  gem.homepage      = 'https://github.com/Verseth/tcr'
  gem.license = 'MIT'

  gem.metadata['homepage_uri'] = gem.homepage
  gem.metadata['source_code_uri'] = gem.homepage
  gem.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gem.files = ::Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  gem.bindir = 'exe'
  gem.executables = gem.files.grep(%r{\Aexe/}) { |f| ::File.basename(f) }
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.7'

  gem.add_development_dependency 'debug'
  gem.add_development_dependency 'geminabox'
  gem.add_development_dependency 'mail'
  gem.add_development_dependency 'mime-types', '~>2.0'
  gem.add_development_dependency 'net-imap'
  gem.add_development_dependency 'net-ldap'
  gem.add_development_dependency 'net-pop'
  gem.add_development_dependency 'net-smtp'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
