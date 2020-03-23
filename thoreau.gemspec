lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thoreau/version'

Gem::Specification.new do |spec|
  spec.name    = 'thoreau'
  spec.version = Thoreau::VERSION
  spec.authors = ['Andrew Peterson']
  spec.email   = ['andy@ndpsoftware.com']

  spec.summary     = %q{A more thoughtful test framework.}
  spec.description = %q{Test add-ins that help make building tests more intentional.}
  spec.homepage    = 'https://github.com/ndp/thoreau'

  #spec.metadata['allowed_push_host'] = 'TODO: Set to \'http://mygemserver.com\''

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ndp/thoreau'
  spec.metadata['changelog_uri']   = 'https://github.com/ndp/thoreau/blob/master/CHANGE_LOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  #spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #  `git ls-files -z`.split('x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  #end
  #spec.bindir        = 'bin'
  #spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'minitest', "~> 5.0"
  spec.add_development_dependency 'simplecov'
end
