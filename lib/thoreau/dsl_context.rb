module Thoreau

  class DSLContext

    attr_reader :equivalence_classes, :action_block, :assertions, :setup_set_hash

    def initialize
      @action              = nil
      @setup_assemblies    = []
      @assertions          = []
      @equivalence_classes = []
    end

    def cases(hash)
      @equivalence_classes = hash.keys.map do |k|
        EquivalenceClass.new(k, hash[k])
      end
    end

    def setup(desc, values = nil, &block)
      pp ''
      @setup_assemblies << SetupAssembler.new(desc, values || block)
    end

    def action(&block)
      @action_block = block
    end

    def asserts(desc, &block)
      @assertions << AssertionBlock.new(desc, block)
    end

    def verify_config!
      @equivalence_classes.each do |ec|
        ec.action_block = @action_block
        warnings = ec.verify_config!(@setup_assemblies, @assertions)
        puts warnings if warnings
      end
    end

    def each_equivalence_class(&block)
      @equivalence_classes.each { |ec| block.call(ec) }
    end
  end
end

