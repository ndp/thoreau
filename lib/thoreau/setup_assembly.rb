# Represents a set of inputs or different setups.
# Setting "values" can be:
# * an enumerable, yielding each value (dynamic is fine). This
#   can be a hard-coded array, or a dynamic randomizing function.
# * a single value
module Thoreau
  class SetupAssembly

    def initialize(desc, values)
      @desc   = desc.to_sym
      @values = values
    end

    def each_setup(&block)
      if @values.respond_to?(:each)
        @values.each(&block)
      else
        block.call(@values)
      end
    end

    def each_setup_block(&block)
      self.each_setup do |setup|
        setup_block = Proc.new { |context| (setup.respond_to? :call) ? context.instance_eval(&setup) : setup }
        block.call(setup_block)
      end
    end
  end
end
