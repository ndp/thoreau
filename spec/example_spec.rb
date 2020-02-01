require_relative './spec_helper'

def dbl(x)
  return nil if x.is_a?(String)
  x * 2 rescue nil
end


RSpec.describe 'Thoreau: example' do

  cases 'any integer input': 'doubles the input',
        'nil input':         'returns nil',
        'any string input':  'returns nil'

  action { |input| dbl(input) }

  setup('any integer input', [0, -1, 1, 1 << 32, -(1 << 32)])
  setup 'nil input', nil
  setup('any string input', ['', 'foo', '*' * 10000] )

  asserts 'doubles the input' do |actual, input|
    expect(actual).to eq (input << 1)
  end

  asserts 'returns nil' do |actual|
    expect(actual).to eq nil
  end

  generate!

end
