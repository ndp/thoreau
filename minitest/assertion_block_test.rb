require_relative './test_helper'

describe Thoreau::AssertionBlock do
  thoreau do

    cases '`exec_in_context`' => [
      'context variables are available in block',
      'passes in `setup_value` to block given',
      'passes in `result` to block given'
    ]

    setup '`exec_in_context`' do
      Thoreau::AssertionBlock.new('desc', -> (action_result, setup_value_result) do
        @setup_value = setup_value_result
        @result      = action_result
      end)
    end

    action do |subject|
      @context = Object.new
      @context.instance_variable_set(:combos_of, 'bar')
      subject.exec_in_context(@context, 'result', 'setup value')
    end

    asserts 'context variables are available in block' do
      _(@context.instance_variable_get(:combos_of)).must_be :==, 'bar'
    end

    asserts 'passes in `setup_value` to block given' do
      _(@context.instance_variable_get(:@setup_value)).must_be :==, 'setup value'
    end

    asserts 'passes in `result` to block given' do
      _(@context.instance_variable_get(:@result)).must_be :==, 'result'
    end
  end
end
