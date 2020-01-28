require_relative './spec_helper'

RSpec.describe Thoreau::AssertionBlock do

  describe 'identifiers' do

    cases 'described with string' => ['`key` is symbol', '`description` is string'],
          'described with symbol' => ['`key` is symbol', '`description` is string']

    setup("described with string") { 'description' }
    setup("described with symbol") { :description }

    action do |input|
      Thoreau::AssertionBlock.new(input, 1)
    end

    asserts "`key` is symbol" do |subject|
      expect(subject.key).to eq(:description)
    end

    asserts "`description` is string" do |subject|
      expect(subject.description).to eq('description')
    end

    generate!
  end

  cases '`exec_in_context`' => [
    'context variables are available in block',
    'passes `setup_value` to block',
    'passes result of action to block'
  ]

  setup '`exec_in_context`' do
    Thoreau::AssertionBlock.new('desc', -> (result, setup_value) do
      @setup_value = setup_value
      @result      = result
    end)
  end

  action do |subject|
    @context = Object.new
    @context.instance_variable_set(:@foo, 'bar')
    subject.exec_in_context(@context, 'result', 'setup value')
  end

  asserts 'context variables are available in block' do
    expect(@context.instance_variable_get(:@foo)).to eq 'bar'
  end

  asserts 'passes `setup_value` to block' do
    expect(@context.instance_variable_get(:@setup_value)).to eq 'setup value'
  end

  asserts 'passes result of action to block' do
    expect(@context.instance_variable_get(:@result)).to eq 'result'
  end

  generate!

end
