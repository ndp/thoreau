require 'minitest/spec'
require 'minitest/autorun'
require 'active_support'
require 'active_support/core_ext/hash'
require_relative 'lib/thoreau'
require 'minitest/pride'

def concat(a, b)
  a + b
end

def double(x)
  return nil if x.is_a?(String)
  x * 2 rescue nil
end

############################
# DSL
def thoreau(&block)
  dsl_context = Thoreau::DSLContext.new
  dsl_context.instance_eval(&block)
  dsl_context.verify_config!
  dsl_context.lock!

  dsl_context.each_equivalence_class do |ec|
    describe ec.setup_key do
      ec.each_test do |setup_block, action_block, assertion|
        temp_context = Object.new
        setup_value  = setup_block.call(temp_context)

        specify "#{ec.setup_key} #{assertion.desc} when  #{setup_value.to_s.truncate(30)}" do

          # Transfer any variables set in the `setup` into the
          # actual test context
          temp_context.instance_variables.each do |iv|
            self.instance_variable_set(iv, temp_context.instance_variable_get(iv))
          end

          # Action
          result = self.instance_exec(setup_value, &action_block) if action_block

          # Assertion
          assertion.exec_in_context(self, result, setup_value)
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
    _(actual).must_be :==, (input << 1)
  end

  asserts 'returns nil' do |actual|
    _(actual).must_be :==, nil
  end

end


describe Thoreau::SetupSet do

  thoreau do

    cases 'single hard-coded value' => 'returns value',
          'hard-coded values'       => 'returns values',
          'single proc'             => 'returns value',
          'procs'                   => 'returns values',
          'generator'               => 'returns values',
          'nil'                     => 'returns nil'

    setup('single hard-coded value') { 1 }
    setup('hard-coded values') { [1, 2, 'three'] }
    setup('single proc') { -> (_) { 1 } }
    setup('procs') { [-> (_) { 1 }, -> (_) { 2 }, -> (_) { 'three' }] }
    setup 'generator' do
      Object.new.tap do |o|
        def o.each
          yield(1)
          yield(2)
          yield('three')
        end
      end
    end
    setup 'nil', nil

    action do |input|
      subject = Thoreau::SetupSet.new('desc', input)
      [].tap do |result|
        subject.each_setup_block { |b| result << b.call }
      end
    end

    asserts('returns value') { |result| _(result).must_be :==, [1] }
    asserts('returns values') { |result| _(result).must_be :==, [1, 2, 'three'] }
    asserts('returns nil') { |result| _(result).must_be :==, [nil] }

  end
end

describe Thoreau::Assertion do
  thoreau do

    cases '`exec_in_context`' => [
      'calls block given in context',
      'passes in `setup_value` to block given',
      'passes in `result` to block given'
    ]

    setup '`exec_in_context`' do
      Thoreau::Assertion.new('desc', -> (result, setup_value) do
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
      _(@context.instance_variable_get(:@foo)).must_be :==, 'bar'
    end
    asserts 'passes in `setup_value` to block given' do
      _(@context.instance_variable_get(:@setup_value)).must_be :==, 'setup value'
    end
    asserts 'passes in `result` to block given' do
      _(@context.instance_variable_get(:@result)).must_be :==, 'result'
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
      _(input).must_be :==, 'input'
    end

    asserts '`asserts` receives output of action' do |result|
      _(result).must_be :==, 'input1'
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
      _(@a).must_be :==, 'a'
    end

    asserts 'between `action` and `assertion`' do
      _(@b).must_be :==, 'aa'
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

  # allows nil setup
  # fails if no assertion
  # complains if more than one setup with the same name
  # complains if more than one action
  # complains if more than one asserts with the same name
  # warns about unused setups
  # warns about unused asserts


end
