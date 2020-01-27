require_relative './spec_helper'

RSpec.describe Thoreau::Assertion do

  describe 'context of `exec_in_context`' do

    cases 'happy path' => [
      'calls `setup` and `asserts` in same context',
      'passes `setup_value` to block given',
      'passes `result` of action to block given'
    ]

    setup 'happy path' do
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

    asserts 'calls `setup` and `asserts` in same context' do
      expect(@context.instance_variable_get(:@foo)).to eq 'bar'
    end
    asserts 'passes `setup_value` to block given' do
      expect(@context.instance_variable_get(:@setup_value)).to eq 'setup value'
    end
    asserts 'passes `result` of action to block given' do
      expect(@context.instance_variable_get(:@result)).to eq 'result'
    end

    generate!

  end
end
