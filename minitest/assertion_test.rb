require_relative './test_helper'

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
