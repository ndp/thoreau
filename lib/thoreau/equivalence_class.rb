# Represents a group of tests with a set of one or more setups,
# an `action_block`, and one or more assertions, or post-conditions.

module Thoreau
  class EquivalenceClass
    attr_accessor :setup_keys
    attr_accessor :asserts_keys
    attr_accessor :setup
    attr_accessor :action_block
    attr_accessor :assertions

    def initialize(setup_keys, asserts_keys)
      @setup_keys   = Array(setup_keys).map(&:to_sym)
      @asserts_keys = [asserts_keys].flatten.map(&:to_sym)
      @assertions   = []
    end

    def inspect
      "EquivalenceClass #{@setup_keys} => #{@asserts_keys}"
    end

    def verify_config!(setup_assemblies, assertions)

      warnings = ''

      missing_setups = []
      @setup_assemblies = []
      @setup_keys.each do |setup_key|
        setup = setup_assemblies.find do |assembly|
          setup_key == assembly.key
        end
        if setup.nil?
          missing_setups << setup_key
        else
          @setup_assemblies << setup
        end
      end

      if missing_setups.any?
        available_keys = setup_assemblies.map(&:description).map { |x| "`#{x}`" }.to_sentence
        warnings << "# WARNING: Setup not defined for `#{missing_setups.join(',')}` so null setup will be used. Consider adding:\n"
        missing_setups.each do |setup|
          warnings << "    setup \"#{setup.to_s}\" do\n"
          warnings << "    end\n"
        end
        warnings << "# Available: #{available_keys}\n" unless available_keys.empty?
      end

      available_keys = assertions.map(&:description).map { |x| "`#{x}`" }.to_sentence
      @asserts_keys.each do |key|
        assertion = assertions.find { |a| a.key == key }
        if assertion
          @assertions << assertion
        else
          warnings << "# WARNING: Assertion not defined for `#{key}` so no test will be generated. Consider adding:\n"
          warnings << "    asserts \"#{key.to_s}\" do | result |\n"
          warnings << "    end\n"
          warnings << "# Available: #{available_keys}\n" unless available_keys.empty?
        end
      end
      warnings.size > 0 ? warnings : nil
    end

    def each_test(&block)
      @setup_assemblies.each do |assembly|
        assembly.setup_blocks.each do |setup_block|
          @assertions.each do |assertion|
            block.call(setup_block, @action_block, assertion)
          end
        end
      end
    end

  end
end
