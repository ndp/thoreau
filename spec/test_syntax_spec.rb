require 'thoreau/v2/dsl'


include Thoreau::V2::DSL

# A test suite has a title
suite "title" do
  testing do
    true
  end

  happy output: true
  happy input: nil, output: true
  happy input: {}, output: true
  happy input: {a: 8}, output: true
end

suite "failures" do
  testing do
    raise "poopy butt"
  end

  sad raises: "poopy butt"
  sad raises: "poopy butts"
  sad raises: Exception
end

suite "parameters" do
  testing do
    a # echo back the a parameter
  end

  happy input: { a: 5 }, output: 6
  happy inputs: { a: 5 }, output: 5, desc: '"inputs" can be plural'
end


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

include Thoreau::V2::DSL

suite do
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
    inputs # what are the inputs we care about

    setups # what are commend set-up scenarios

    outputs # what are the outputs we care about

    expectations
  end
end

