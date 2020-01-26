require_relative './test_helper'

def double(x)
  return nil if x.is_a?(String)
  x * 2 rescue nil
end


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
