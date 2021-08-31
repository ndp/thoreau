
require 'rspec/core'
require 'thoreau'
require 'thoreau/rspec/example_helpers'
require 'thoreau/rspec/configuration'
require 'thoreau/rspec/railtie' if defined?(Rails::Railtie)

module Thoreau
  module Rspec

    ::RSpec.configure do |c|
      c.include ExampleHelpers
    end

    def self.config
      @config ||= Configuration.new(RSpec.configuration)
    end
  end
end
