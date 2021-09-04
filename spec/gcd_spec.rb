require 'thoreau'

include Thoreau::DSL


def gcd(a, b)
  if (a == 0)
    return b
  end

  while b != 0
    if a > b
      a = a - b
    else
      b = b - a;
    end
  end

  return a
end

suite 'greatest common divisor' do
  testing do
    gcd(a, b)
  end

  cases do
    happy inputs: { a: 12, b: 9 }, output: 3
    happy inputs: { a: 9, b: 12 }, output: 3
    happy inputs: [{ a: 10, b: 9 }, { a: 10, b: 9 }], output: 1
    happy inputs: { a: 100, b: 25 }, output: 25

    # edges :none

    boundary inputs: { a: 0, b: 0 }, output: 0
    boundary inputs: { a: 1, b: 1 }, output: 1
    boundary inputs: { a: 0, b: 100 }, output: 100
    boundary inputs: { a: 100, b: 0 }, output: 100

    corner inputs: { a: 1, b: 100 }, output: 1
  end

  appendix do
    # inputs # what are the inputs we care about

    # setups # what are commend set-up scenarios

    # outputs # what are the outputs we care about

    # expectations
  end
end

