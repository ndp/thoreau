# Represents a group of tests with a set of one or more setups,
# an `action_block`, and one or more assertions, or post-conditions.

module Thoreau
  class EquivalenceClass
    attr_accessor :setup_key
    attr_accessor :asserts_keys
    attr_accessor :setup
    attr_accessor :action_block
    attr_accessor :assertions

    def initialize(setup_key, asserts_keys)
      @setup_key    = setup_key.to_sym
      @asserts_keys = [asserts_keys].flatten.map(&:to_sym)
    end

    def inspect
      "EquivalenceClass #{@setup_key} => #{@asserts_keys}"
    end

    def each_test(&block)
      @setup.each_setup_block do |setup_block|
        @assertions.each do |assertion|
          block.call(setup_block, @action_block, assertion)
        end
      end
    end

  end
end
