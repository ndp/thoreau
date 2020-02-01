
require 'rspec/core'
require 'thoreau'
require 'thoreau/rspec/example_group_helpers'
require 'thoreau/rspec/example_helpers'
require 'thoreau/rspec/configuration'
require 'thoreau/rspec/railtie' if defined?(Rails::Railtie)

module Thoreau
  module Rspec

    # Extend RSpec with a swagger-based DSL
    ::RSpec.configure do |c|
      #c.add_setting :swagger_root
      c.extend ExampleGroupHelpers
      c.include ExampleHelpers
    end

    def self.config
      @config ||= Configuration.new(RSpec.configuration)
    end
  end
end
