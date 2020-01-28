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
      @assertions   = []
    end

    def inspect
      "EquivalenceClass #{@setup_key} => #{@asserts_keys}"
    end

    def verify_config!(setup_assemblies, assertions)

      setup_assemblies.each do |setup|
        @setup = setup if @setup_key == setup.key
      end
      if @setup.nil?
        available_keys = setup_assemblies.map(&:key)
        puts "# WARNING: Setup not defined for `#{@setup_key}` so null setup will be used. Consider adding:"
        puts "    setup \"#{@setup_key.to_s}\" do"
        puts "    end"
        puts "# Available: #{available_keys}" unless available_keys.empty?
        @setup = SetupAssembly.new('ec.setup_key', nil)
      end

      available_keys = assertions.map(&:key)
      @asserts_keys.each do |key|
        assertion = assertions.find { |a| a.key == key }
        if assertion
          @assertions << assertion
        else
          puts "# WARNING: Assertion not defined for `#{key}` so no test will be generated. Consider adding:"
          puts "    asserts \"#{key.to_s}\" do | result |"
          puts "    end"
          puts "# Available: #{available_keys}" unless available_keys.empty?
        end
      end
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
