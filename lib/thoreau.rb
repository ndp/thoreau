require_relative 'thoreau/version'
require_relative 'thoreau/v2/dsl'

module Thoreau
  class Error < StandardError;
  end
  # Your code goes here...
end

if defined?(RSpec)
  require_relative('./thoreau/rspec')
end
