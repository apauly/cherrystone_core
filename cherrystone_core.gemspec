# frozen_string_literal: true

require_relative 'lib/cherrystone_core/version'

Gem::Specification.new do |spec|
  spec.name = 'cherrystone_core'
  spec.version = CherrystoneCore::VERSION
  spec.authors = ['Alexander Pauly']
  spec.email = ['alex.pauly@posteo.de']

  spec.summary = 'Write summary'
  spec.description = 'Write summary'
  spec.homepage = 'https://github.com/apauly/cherrystone_core'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6')

  spec.files = Dir['{app,config,db,lib}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'docile'
  spec.add_dependency 'rails', '> 6.0'

  spec.add_development_dependency 'amazing_print'
  spec.add_development_dependency 'pry-byebug'

  #spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'shoulda-matchers'

  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov'
end
