require_relative './test_helper'

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
end
