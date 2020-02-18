require_relative './spec_helper'

def dbl(x)
  return nil if x.is_a?(String)
  x * 2 rescue nil
end


RSpec.describe 'Thoreau: Example using named variables' do

  cases 'any integer `i`':  'doubles the input',
        'nil input':        'returns nil',
        'any string input': 'returns nil'

  action { dbl(i) }

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

RSpec.describe 'Thoreau: Example using implicit variables' do

  cases 'any integer':      'doubles the input',
        'nil input':        'returns nil',
        'any string input': 'returns nil'

  action { |input| dbl(input) }

  setup('any integer `i`', [0, -1, 1, 1 << 32, -(1 << 32)])
  setup 'nil input', nil
  setup('any string input', ['', 'foo', '*' * 10000])

  asserts 'doubles the input' do |actual, i|
    expect(actual).to eq (i << 1)
  end

  asserts 'returns nil' do |actual|
    expect(actual).to eq nil
  end

  generate!

end
