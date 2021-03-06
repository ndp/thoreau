require_relative 'thoreau/version'
require_relative 'thoreau/setup_assembler'
require_relative 'thoreau/assertion_block'
require_relative 'thoreau/equivalence_class'
require_relative 'thoreau/dsl_context'

module Thoreau
  class Error < StandardError;
  end
  # Your code goes here...
end

if defined?(RSpec)
  require_relative('./thoreau/rspec')
end
