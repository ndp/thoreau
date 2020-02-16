# Represents a set of inputs or different setups.
# Setting "values" can be:
# * an enumerable, yielding each value (dynamic is fine). This
#   can be a hard-coded array, or a dynamic randomizing function.
# * a single value
module Thoreau
  class SetupAssembly

    def initialize(desc, values, &block)
      @desc   = desc
      @values = block || values
    end

    def description
      @desc.to_s
    end

    def key
      @desc.to_sym
    end

    # [[[:i, 1], [:i, 2], [:i, 3]], [[:b, true]]]
    # [[[:i, 1],[:b, true]],[[:i, 2],[:b, true]],[[:i, 3],[:b, true]]]
    def combos_of(entries)
      first = entries.first
      rest  = entries.slice(1..10)
      if rest.empty?
        return [first]#.map {|f| [f]}
      end
      pp entries: entries, first: first, rest: rest

      combos_of_rest = combos_of(rest)
      pp combos_of_rest: combos_of_rest

      result = first.map do |e|
        add_this = [e].append(*combos_of_rest)
        pp add_this: add_this, first: first, e: e
           add_this
      end.first
      pp result: result
      result
    end

    def setup_blocks
      vars = []
      @values.entries.each do |entry|
        vars.push Array(entry[1]).map { |v| [entry[0], v] }
      end
      pp VARS: vars
      combos = combos_of(vars)
      pp COMBOS: combos
      combos.map do |values|
        map = values.to_h
        pp map: map
        create_setup_block(map)
      end
    end

    #def each_setup
    #  yield
    #  return
    #  pp each_setup: @values, klass: @values.class, each?: @values.respond_to?(:each)
    #  if @values.is_a?(Hash)
    #    pp 'x' * 10
    #    @values.keys.reduce({}) do |m, k|
    #      pp k: k, v: @values[k], block: block, each: @values[k].respond_to?(:each)
    #      v        = @values[k]
    #      #my_block = -> () {
    #      #  instance_variable_set("@#{k}", v)
    #      #}
    #      #context =Object.new
    #      #pp block.binding
    #      #context.instance_exec(&block)
    #      yield
    #
    #      #result = block.call(my_block)
    #      #pp result222: result
    #      #yield my_block
    #      #instance_variable_set("@#{k}", result)
    #      m
    #    end
    #  else
    #    apply_to(@values, &block)
    #  end
    #end

    #def each_setup_block(&block)
    #  self.each_setup do |setup|
    #    pp setup: setup
    #    setup_block = Proc.new { |context| (setup.respond_to? :call) ? context.instance_eval(&setup) : setup }
    #    block.call(68)
    #  end
    #end

    def apply_to(values, &block)
      if values.respond_to?(:each)
        values.each(&block)
      else
        block.call(values)
      end
    end

    private

    def create_setup_block(map_of_values)
      proc do |context|
        map_of_values.each do |key, val|
          context.instance_variable_set("@#{key}", val)
          # add method to the eigenclass
          (
          class << context;
            self;
          end).send(:define_method, key) { val }
        end
      end
    end
  end
end
