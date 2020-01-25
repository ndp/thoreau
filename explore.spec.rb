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


class SetupSet

  def initialize(desc, details, block)
    @desc    = desc.to_sym
    @details = details && [details].flatten
    @block   = block
  end

  def each(&block)
    #@details ? @details.each(&block) : block.call(@block)
    @details ? @details.each(&block) : block.call(@block)
  end

  def each_setup_block(&block)

  end

  #          setup_value = (setup.respond_to? :call) ? context.instance_eval(&setup) : setup
end

class Assertion

  attr_accessor :desc
  attr_accessor :block

  def initialize(desc, block)
    @desc  = desc.to_sym
    @block = block
  end

  def exec_in_context(context, result, setup_value)
    context.instance_exec(result, setup_value, &@block)
  end

end

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
    "EquivalenceClass #{@setup_key}: #{@asserts_keys}"
  end

  def each_test(&block)
    @setup.each do |setup|
      @assertions.each do |assertion|
        setup_block = Proc.new { |context| (setup.respond_to? :call) ? context.instance_eval(&setup) : setup }
        block.call(setup_block, @action_block, assertion)
      end
    end
  end

end

class SuiteDSL

  attr_reader :equivalence_classes, :action_block, :assertions, :setup_set_hash

  def initialize
    @action         = nil
    @setup_set_hash = {}
    @assertions     = {}
  end

  def cases(hash)
    @equivalence_classes = hash.keys.map { |k| EquivalenceClass.new(k, hash[k]) }
  end

  def setups(setup_key, details = nil, &block)
    @setup_set_hash[setup_key.to_sym] = SetupSet.new(setup_key, details, block)
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
        specify "#{ec.setup_key}: given #{setup_value.to_s.truncate(30)} #{assertion.desc}" do
          result = test_context.instance_exec(setup_value, &action_block)
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

#describe 'double()' do

thoreau do
  action { |input| double(input) }

  cases 'any integer input': ['doubles the input'],
        'nil input':         'returns nil',
        'any string input':  'returns nil'

  setups 'any integer input', [0, -1, 1, 1 << 32, -(1 << 32)]
  setups 'nil input', nil
  setups 'any string input', ['', 'foo', '*' * 10]

  asserts 'doubles the input' do |actual, input|
    actual.must_be :==, (input << 1)
  end

  asserts 'returns nil' do |actual|
    actual.must_be :==, nil
  end

end
#end

describe 'dsl' do

  thoreau do

    cases 'a constant input' => [
      'asserts receives input of action',
      'asserts receives output of action'
    ]

    setups 'a constant input', 'input'

    action { |input| input + '1' }

    asserts 'asserts receives input of action' do |_result, input|
      input.must_be :==, 'input'
    end

    asserts 'asserts receives output of action' do |result|
      result.must_be :==, 'input1'
    end
  end

  thoreau do

    cases 'dynamic contexts': [
                                'context transferred from setup',
                                'context transferred from action'
                              ]

    setups 'dynamic contexts' do
      @a = 'a'
      @b = @a
    end

    action do
      @b *= 2
    end

    asserts 'context transferred from setup' do
      @a.must_be :==, 'a'
    end

    asserts 'context transferred from action' do
      @b.must_be :==, 'aa'
    end
  end

  thoreau do
    cases a_context: 'a single assertion',
          an_input:  ['a single assertion', 'another assertion']

    setups :a_context do
      rand(2)
    end

    setups :an_input, 'input'

    action { true }

    asserts 'a single assertion' do

    end
    asserts 'another assertion' do

    end
  end


end
