require_relative './spec_helper'

def example_fn(x)
  return nil if x.is_a?(String)
  x * 2 rescue nil
end


RSpec.describe 'Example using implicit data' do

  cases 'any integer': 'doubles the input',
        'nil input':   'returns nil',
        'any string':  'returns nil'

  action { |input| example_fn(input) }

  setup('any integer', [0, -1, 1, 1 << 32, -(1 << 32)])
  setup 'nil input', nil
  setup('any string', ['', 'foo', '*' * 10000])

  asserts 'doubles the input' do |actual, i|
    expect(actual).to eq (i << 1)
  end

  asserts 'returns nil' do |actual|
    expect(actual).to eq nil
  end

  generate!

end

RSpec.describe 'Example using named variables' do

  cases 'any integer `i`':  'doubles the input',
        'nil input':        'returns nil',
        'any string input': 'returns nil'

  action { example_fn(i) }

  setup('any integer `i`', i: [0, -1, 1, 1 << 32, -(1 << 32)])
  setup 'nil input', i: nil
  setup('any string input', i: ['', 'foo', '*' * 10000])

  asserts 'doubles the input' do |actual|
    expect(actual).to eq (i << 1)
  end

  asserts 'returns nil' do |actual|
    expect(actual).to eq nil
  end

  generate!

end

RSpec.describe 'Example using setup blocks' do

  cases 'an integer':     'doubles the input',
        'nil input':      'returns nil',
        'a string input': 'returns nil'

  action { @result = example_fn(@i) }

  setup('an integer') do
    @i = 13
  end
  setup 'nil input'
  setup('a string input') do
    @i = 'foo'
  end

  asserts 'doubles the input' do
    expect(@result).to eq 26
  end

  asserts 'returns nil' do
    expect(@result).to eq nil
  end

  generate!

end

