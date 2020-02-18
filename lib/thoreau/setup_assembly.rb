# Represents a set of inputs or different setups.
# Setting "values" can be:
# * an enumerable, yielding each value (dynamic is fine). This
#   can be a hard-coded array, or a dynamic randomizing function.
# * a single value
module Thoreau
  class SetupAssembly

    IMPLICIT_VAR_NAME = :input # used when the user has just one, unnamed variable

    def initialize(desc, values = nil, &block)
      @desc   = desc
      @block  = block
      @values = case values
                when Hash
                  values
                when nil
                  { input: nil }
                when Proc
                  @block = values
                  nil
                else
                  { input: values }
                end
    end

    def description
      @desc.to_s
    end

    def key
      @desc.to_sym
    end

    # a single set-up block for a test
    class Setup
      def initialize(description, map_of_values)
        @desc          = description
        @map_of_values = map_of_values
        @proc          = proc do |context|
          map_of_values.each do |key, val|
            raise "`#{key}` is already defined in the context. This will be confusing." if context.respond_to?(key) && key != IMPLICIT_VAR_NAME
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
        result = @desc

        if @map_of_values.keys == [IMPLICIT_VAR_NAME] # if just one value,
          v      = @map_of_values[IMPLICIT_VAR_NAME].to_s
          result += " (#{v})" unless v.match?(/^\[?#</) || result.include?(v)
        else
          result += " (#{@map_of_values.keys.sort.map { |k| "#{k}=#{@map_of_values[k].pretty_inspect.strip.truncate(30)}" }.join(' ')})"
        end
        result
      end

      def call(*args)
        implicit_param @proc.call(*args)
      end

      private
      def implicit_param(params)
        params.is_a?(Hash) &&
          params.keys == [SetupAssembly::IMPLICIT_VAR_NAME] ?
          params[SetupAssembly::IMPLICIT_VAR_NAME] : params
      end

    end

    def setup_blocks
      if @block
        return [Proc.new do |context|
          context.instance_eval(&@block).tap do |result|
            (
            class << context;
              self;
            end).send(:define_method, IMPLICIT_VAR_NAME) { result }
          end
        end]
      end

      case @values
      when Hash
        # expand iterable values, eg. `i=>[1,2]` to [[:i, 1], [:i,2]]
        vars = []
        @values.entries.each do |entry|
          # map, but we just want to work with a simple `each`
          result = []
          (entry[1].respond_to?(:each) ? entry[1] : Array(entry[1])).each do |v|
            result << [entry[0], v]
          end
          vars.push result
        end
        combos_of(vars).map { |values| Setup.new(@desc, values) }

      else
        raise "huh? #{@values}"
      end
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
