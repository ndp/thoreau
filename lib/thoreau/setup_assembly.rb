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

    class Setup
      def initialize(description, map_of_values)
        @desc          = description
        @map_of_values = map_of_values
        @proc          = proc do |context|
          map_of_values.each do |key, val|
            raise "`#{key}` is already defined in the context. This will be confusing." if context.respond_to?(key)
            context.instance_variable_set("@#{key}", val)
            # add method to the eigenclass
            (
            class << context;
              self;
            end).send(:define_method, key) { val }
          end
        end
      end

      def description
        @desc + " with#{@map_of_values.keys.sort.map { |k| " #{k}=#{@map_of_values[k]}" }.join}"
      end

      def call(*args)
        @proc.call(*args)
      end
    end

    def setup_blocks
      # expand iterable values, eg. `i=>[1,2]` to [[:i, 1], [:i,2]]
      vars = []
      @values.entries.each do |entry|
        vars.push Array(entry[1]).map { |v| [entry[0], v] }
      end
      combos_of(vars).map { |values| Setup.new(@desc, values) }
    end

    def apply_to(values, &block)
      if values.respond_to?(:each)
        values.each(&block)
      else
        block.call(values)
      end
    end

    def combos_of(entries)
      return [{}] if entries.size == 0

      first_response = entries.first.map { |x| { x[0] => x[1] } }
      return first_response if entries.size == 1

      combos_of_rest = combos_of(entries.slice(1..(entries.size)))

      first_response.flat_map do |f|
        combos_of_rest.map { |r| r.merge(f) }
      end
    end

  end
end
