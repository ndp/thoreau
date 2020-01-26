module Thoreau

  class DSLContext

    attr_reader :equivalence_classes, :action_block, :assertions, :setup_set_hash

    def initialize
      @action              = nil
      @setup_set_hash      = {}
      @assertions          = {}
      @equivalence_classes = []
    end

    def cases(hash)
      @equivalence_classes = hash.keys.map { |k| EquivalenceClass.new(k, hash[k]) }
    end

    def setup(setup_key, values = nil, &block)
      @setup_set_hash[setup_key.to_sym] = SetupSet.new(setup_key, values || block)
    end

    def action(&block)
      @action_block = block
    end

    def asserts(desc, &block)
      @assertions[desc.to_sym] = Assertion.new(desc, block)
    end

    def verify_config!
      @equivalence_classes.each do |ec|
        s = @setup_set_hash[ec.setup_key]
        puts "# WARNING: Setup not defined for `#{ec.setup_key}` so null setup will be used. Defined: #{@setup_set_hash.keys}" unless s

        ec.asserts_keys.each do |key|
          raise "Asserts not defined for `#{ec.setup_key}`. Defined: #{@assertions.keys}" unless @assertions[key]
        end
      end
    end

    def lock!
      @equivalence_classes.each do |ec|
        ec.setup        = @setup_set_hash[ec.setup_key] || SetupSet.new('ec.setup_key', nil)
        ec.action_block = @action_block
        ec.assertions   = ec.asserts_keys.map { |desc| @assertions[desc] }
      end
    end

    def each_equivalence_class(&block)
      @equivalence_classes.each { |kase| block.call(kase) }
    end
  end
end

