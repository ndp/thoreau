require_relative 'thoreau/version'
require_relative 'thoreau/dsl'
require_relative 'thoreau/configuration'

module Thoreau
  def self.configure &block
    block.call configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end

if defined?(RSpec)
  require_relative('./thoreau/rspec')
end
