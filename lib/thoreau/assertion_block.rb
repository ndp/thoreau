# Represents a post-condition of a test.
# A test will be created for each assertion in the "one assertion per test" tradition.
# The block is
# * passed the result of the action as its first argument
# * passed the setup value as the second argument
# * will be executed in the same test context as the setup and action code

module Thoreau

  class AssertionBlock

    attr_accessor :desc

    def initialize(desc, block)
      @desc  = desc.to_s
      @block = block
    end

    def exec_in_context(context, action_result, setup_value)
      context.instance_exec(action_result, setup_value, &@block)
    end

  end
end
