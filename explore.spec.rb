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


class Setup

  def initialize(desc, details, block)
    @desc    = desc.to_sym
    @details = details && [details].flatten
    @block   = block
  end

  def each(&block)
    pp 'Setup.each', details: @details, block: @block
    @details ? @details.each(&block) : block.call(@block.call)
  end
end

class Case
  extend Forwardable

  attr_accessor :desc
  def_delegators :@tests, :each

  def initialize(desc, tests)
    @desc  = desc.to_sym
    @tests = [tests].flatten.map(&:to_sym)
  end

  def inspect
    "Case #{@desc}: #{@tests}"
  end

end

class SuiteDSL

  attr_reader :action_block, :assertions, :setups_hash

  def initialize
    @action      = nil
    @setups_hash = {}
    @assertions  = {}
  end

  def action &block
    @action_block = block
  end

  def asserts desc, &block
    @assertions[desc.to_sym] = block
  end

  def setups desc, details = nil, &block
    @setups_hash[desc.to_sym] = Setup.new(desc, details, block)
  end

end

def cases hash, &block
  @cases = hash.keys.map { |k| Case.new(k, hash[k]) }

  suite = SuiteDSL.new
  suite.instance_eval(&block)

  @cases.each do |kase|
    setups = suite.setups_hash[kase.desc]
    raise "Set up not defined for `#{kase.desc}`. Defined: #{suite.setups_hash.keys}" unless setups

    describe kase.desc do
      pp setups: setups

      setups.each do |setup|
        kase.each do |test|
          raise "Asserts not defined for `#{kase.desc}`. Defined: #{suite.assertions.keys}" unless suite.assertions[test]
          specify "#{kase.desc}: given #{setup.inspect.truncate(30)} #{test}" do
            context = Object.new
            #pp setup: setup.is_a?(String) ? setup[0..10] : setup, responds: setup.respond_to?(:call)
            setup_value = (setup.respond_to? :call) ? context.instance_eval(setup) : setup
            result      = context.instance_eval { suite.action_block.call(setup_value) }
            context.instance_eval { suite.assertions[test].call(result, setup_value) }
          end
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

#cases any_integer_input: ['doubles the input'],
#      nil_input:         :returns_nil,
#      string_input:      :returns_nil do
#
#  action { |input| double(input) }
#
#  setups :any_integer_input, [0, -1, 1, 1 << 32, -(1 << 32)]
#  setups :nil_input, nil
#  setups :string_input, ['', 'foo', '*' * 10]
#
#  asserts 'doubles the input' do |actual, input|
#    actual.must_be :==, (input << 1)
#  end
#
#  asserts :returns_nil do |actual, input|
#    actual.must_be :==, nil
#  end
#
#end
#end

describe 'dsl' do

  cases a_constant_input: 'an output assertion' do

    setups :a_constant_input, 'input'

    action { |input| input + '1' }

    asserts 'an output assertion' do |result|
      result.must_be :==, 'input1'
    end
  end


  cases a_dynamic_context: [
                             'context transferred from setup',
                             'context transferred from action'
                           ] do

    setups :a_dynamic_context do
      @a = 'a'
      @b = @a
    end

    action do
      pp action: @b
      @b *= 2
      pp action2: @b
    end

    asserts 'context transferred from setup' do
      @a.must_be :==, 'a'
    end

    asserts 'context transferred from action' do
      @b.must_be :==, 'aa'
    end
  end

  cases a_context: 'a single assertion',
        an_input:  ['a single assertion', 'another assertion'] do

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
