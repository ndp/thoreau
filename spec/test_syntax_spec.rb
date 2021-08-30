require 'thoreau/v2/dsl'

include Thoreau::V2::DSL

# A test suite has a title
xsuite "title" do
  testing do
    # This is some code that is run for each test
    # It's the "subject" of the test suite. In this
    # case we just return "true" to get things moving.
    true
  end

  happy output: true
  # If tests don't work, just mark them with "fails" or "pending" and the will be "OK"
  happy output: false, fails: true
  happy output: false, pending: true

  happy "descriptions are available", output: true
end

xsuite "exceptions" do
  testing { raise "poopy butt" }

  sad raises: "poopy butt"
  sad raises: "poopy butts spelt wrong", fails: true
  sad raises: Exception, fails: true
end

xsuite "parameter" do
  testing { a }

  happy input: { a: 5 }, output: 5
  happy input: { a: 5, z: "extra parameters are ignored" }, output: 5
  happy "'input' can have an 's' for readability", inputs: { a: 5, b: 9 }, output: 5
end

xsuite "multiple parameters" do
  testing { a + b }

  happy 'receives both parameters', inputs: { a: 1, b: 3 }, equals: 4
  happy 'raises if missing a parameter',
        inputs: { a: 2 }, fails: true
end

suite "shared setup blocks" do
  testing { a }

  happy "when a is 5", setup: "a_is_5", output: 5
  happy "a_is_5", output: 5
  happy "a_is_7", output: 7

  appendix do
    setup "a_is_5", { a: 5 }
    setup("a_is_7") { a = 7 }
  end
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

xsuite do
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

