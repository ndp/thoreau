# Represents a set of inputs or different setups.
module Thoreau
  class SetupAssembler

    IMPLICIT_VAR_NAME = :input # used when the user has just one, unnamed variable

    # @desc {String} name of the setup assembly, used to build a description and as an identifier.
    # @values {Hash|enumerable|Proc|nil|anything} can be anything that will provide the setup
    # for the test. This can be:
    # * for simple functions an input value (here called "implicit var")
    # * for test subjects requiring multiple values, this can be a hash
    # * for functional tests, this can be a block runs arbitrary Ruby code
    # At the same time, if this is enumerable, multiple test setups will be generated, one for each value.
    def initialize(desc, values = nil, &block)
      @desc           = desc
      @block, @values = values.is_a?(Proc) ? [values, nil] : [block, values]
    end

    def description
      @desc.to_s
    end

    def key
      @desc.to_sym
    end

    def setup_blocks
      return [BlockSetup.new(@desc, @block)] if @block

      case @values
      when Hash
        setups_from_hash(@values)
      else
        setups_from_hash(IMPLICIT_VAR_NAME => @values)
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

    private

    def setups_from_hash(hash)
      vars = []
      hash.entries.map do |key, value|
        [key, value.respond_to?(:each) ? value : Array(value)]
      end.entries.each do |key, value|
        # Note: this could be written as:
        # ```
        # vars.push value.map { |v| result << [key, v] }
        # ```
        # but then if the caller passes in just an `each`, it wouldn't work.
        # TODO figure out how to wrap this... there's gotta be a nice Ruby way.
        result = []
        value.each { |v| result << [key, v] }
        vars.push result
      end
      combos_of(vars).map { |values| HashSetup.new(@desc, values) }
    end

    # a single set-up block for a test
    class HashSetup
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
          params.keys == [SetupAssembler::IMPLICIT_VAR_NAME] ?
          params[SetupAssembler::IMPLICIT_VAR_NAME] : params
      end

    end

    class BlockSetup
      def initialize(desc, block)
        @desc = desc
        @proc = Proc.new do |context|
          context.instance_eval(&block).tap do |result|
            (
            class << context;
              self;
            end).send(:define_method, IMPLICIT_VAR_NAME) { result }
          end
        end
      end

      def description
        @desc
      end

      def call(*args)
        @proc.call(*args)
      end
    end

  end
end
