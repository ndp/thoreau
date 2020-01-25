require 'minitest/spec'
require 'minitest/autorun'
require 'active_support'
require 'active_support/core_ext/hash'

def concat(a, b)
  a + b
end

def double(x)
  return nil if x.is_a?(String)
  x * 2 rescue nil
end

############################
# DSL
require 'forwardable'

# Represents a set of inputs or different setups.
# Setting "values" can be:
# * an enumerable, yielding each value (dynamic is fine). This
#   can be a hard-coded array, or a dynamic randomizing function.
# * a single value
class SetupSet

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

# Represents a post-condition of a test.
# A test will be created for each assertion in the "one assertion per test" tradition.
# The block is
# * passed the result of the action as its first argument
# * passed the setup value as the second argument
# * will be executed in the same test context as the setup and action code
class Assertion

  attr_accessor :desc

  def initialize(desc, block)
    @desc  = desc.to_sym
    @block = block
  end

  def exec_in_context(context, result, setup_value)
    context.instance_exec(result, setup_value, &@block)
  end

end

# Represents a group of tests with a set of one or more setups,
# an `action_block`, and one or more assertions, or post-conditions.
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

class SuiteDSL

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
      raise "Set up not defined for `#{ec.setup_key}`. Defined: #{@setup_set_hash.keys}" unless s

      ec.asserts_keys.each do |key|
        raise "Asserts not defined for `#{ec.setup_key}`. Defined: #{@assertions.keys}" unless @assertions[key]
      end
    end
  end

  def lock!
    @equivalence_classes.each do |ec|
      ec.setup        = @setup_set_hash[ec.setup_key]
      ec.action_block = @action_block
      ec.assertions   = ec.asserts_keys.map { |desc| @assertions[desc] }
    end
  end

  def each_equivalence_class(&block)
    @equivalence_classes.each { |kase| block.call(kase) }
  end
end

def thoreau(&block)
  suite = SuiteDSL.new
  suite.instance_eval(&block)
  suite.verify_config!
  suite.lock!

  suite.each_equivalence_class do |ec|
    describe ec.setup_key do
      ec.each_test do |setup_block, action_block, assertion|
        test_context = Object.new
        setup_value  = setup_block.call(test_context)

        specify "#{ec.setup_key} #{assertion.desc} when  #{setup_value.to_s.truncate(30)}" do
          result = test_context.instance_exec(setup_value, &action_block) if action_block
          assertion.exec_in_context(test_context, result, setup_value)
        end
      end
    end
  end

end


############################
# Test
# Use describe for things.
#Use context for states
# arrange - act - assert


thoreau do
  action { |input| double(input) }

  cases 'any integer input': ['doubles the input'],
        'nil input':         'returns nil',
        'any string input':  'returns nil'

  setup 'any integer input', [0, -1, 1, 1 << 32, -(1 << 32)]
  setup 'nil input', nil
  setup 'any string input', ['', 'foo', '*' * 10000]

  asserts 'doubles the input' do |actual, input|
    actual.must_be :==, (input << 1)
  end

  asserts 'returns nil' do |actual|
    actual.must_be :==, nil
  end

end


describe SetupSet do

  thoreau do

    cases 'single hard-coded value' => 'returns value',
          'hard-coded values'       => 'returns values',
          'proc'                    => 'returns value',
          'generator'               => 'returns values',
          'nil'                     => 'returns nil'

    setup('single hard-coded value') { 1 }
    setup('hard-coded values') { [1, 2, 'three'] }
    setup('proc') { -> (_) { 1 } }
    setup 'generator' do
      o = Object.new
      def o.each
        yield(1)
        yield(2)
        yield('three')
      end
      o
    end
    setup 'nil', nil

    action do |input|
      subject = SetupSet.new('desc', input)
      [].tap do |result|
        subject.each_setup_block { |b| result << b.call }
      end
    end

    asserts('returns value') { |result| result.must_be :==, [1] }
    asserts('returns values') { |result| result.must_be :==, [1, 2, 'three'] }
    asserts('returns nil') { |result| result.must_be :==, [nil] }

  end
end

describe 'Assertion' do
  thoreau do

    cases '`exec_in_context`' => [
      'calls block given in context',
      'passes in `setup_value` to block given',
      'passes in `result` to block given'
    ]

    setup '`exec_in_context`' do
      Assertion.new('desc', -> (result, setup_value) do
        @foo         = 'bar'
        @setup_value = setup_value
        @result      = result
      end)
    end

    action do |subject|
      @context = Object.new
      subject.exec_in_context(@context, 'result', 'setup value')
    end

    asserts 'calls block given in context' do
      @context.instance_variable_get(:@foo).must_be :==, 'bar'
    end
    asserts 'passes in `setup_value` to block given' do
      @context.instance_variable_get(:@setup_value).must_be :==, 'setup value'
    end
    asserts 'passes in `result` to block given' do
      @context.instance_variable_get(:@result).must_be :==, 'result'
    end
  end
end

describe 'dsl' do

  thoreau do

    cases 'a constant input' => [
      '`asserts` receives input of action',
      '`asserts` receives output of action'
    ]

    setup 'a constant input', 'input'

    action { |input| input + '1' }

    asserts '`asserts` receives input of action' do |_result, input|
      input.must_be :==, 'input'
    end

    asserts '`asserts` receives output of action' do |result|
      result.must_be :==, 'input1'
    end
  end

  thoreau do

    cases 'contexts shared': [
                               'between `setups` and `assertion`',
                               'between `action` and `assertion`'
                             ]

    setup 'contexts shared' do
      @a = 'a'
      @b = @a
    end

    action do
      @b *= 2
    end

    asserts 'between `setups` and `assertion`' do
      @a.must_be :==, 'a'
    end

    asserts 'between `action` and `assertion`' do
      @b.must_be :==, 'aa'
    end
  end

  thoreau do
    cases a_context: 'a single assertion',
          an_input:  ['a single assertion', 'another assertion']

    setup :a_context do
      rand(2)
    end

    setup :an_input, 'input'

    action { true }

    asserts 'a single assertion' do

    end
    asserts 'another assertion' do

    end
  end


end
