require 'thoreau/auto_run'

include Thoreau::DSL

# This file shows the basics of the Thoreau syntax.
# It was also used to test-drive the implementation.

suite "test output equality" do
  # A test suite has a title

  subject do
    # This is some code that is run for each test
    # It's the "subject" of the test suite. In this
    # case we just return "true", but you'll be
    # calling whatever code you want to test.
    true
  end

  happy "output matches result of test block", output: true
  happy "output equals result of test block", equals: true # equals/output are the same

  # If tests don't work, just mark them with "fails" or "pending" and the will be "OK"
  happy "tests marked 'fails' must fail", output: false, fails: true
  happy "tests marked 'pending' must fail", output: false, pending: true

  happy "tests can have doescriptions", output: true
  happy output: true # or not-- through will generate the best one it can

  # If procs are provided, they are evaluated before checking for equality.
  happy "tests equivalence of proc result", equals: proc { nil.nil? }
  happy "tests equivalence of proc result (negative case)",
        equals: proc { 3 == 4 },
        fails:  true

end

suite 'nested tests' do
  # Tests with different subjects must be separated
  # into "test_cases" blocks, and each of these has
  # a subject. There is no "overriding"-- you do it
  # one way or the other.

  test_cases 'simple nesting' do
    subject { 1 }

    happy equals: 1
  end

  test_cases 'using setup from the appendix' do
    subject { i }

    happy equals: 2, setup: 'two'
  end

  # all tests share a single "appendix"
  appendix do
    setup 'two', { i: 2 }
  end

end

# Expectations can be written around exceptions as well.
suite "exceptions" do
  subject { raise "not on my watch" }

  sad raises: "not on my watch"
  sad raises: "not on my iWatch", fails: true
  sad "wrong exception type", raises: Exception, fails: true
end

# When testing real code, you'll need to pass parameters into your
# testing action. That is done with input/inputs on the test case.
# This is always a hash of values that get turned into variables within
# the testing block.
suite "parameter" do
  subject { a }

  happy "input parameter passes to test block", input: { a: 5 }, output: 5
  happy "'input' can have an 's' for readability", inputs: { a: 5, b: 9 }, output: 5
end

# Of course multiple parameters are fine.
suite "multiple parameters" do
  subject { a + b }

  happy 'receives both params', inputs: { a: 1, b: 3 },
        equals:                         4
  happy 'raises if missing a parameter',
        inputs: { a: 2 },
        fails:  true
  happy 'extra params are ignored',
        input:  { a: 5, b: 7, z: "ignored" },
        output: 12
end

# "Setups" are blocks that can be shared amongst your
# tests. Unlike other test frameworks, setups must be
# specified explicitly on the test itself. This should
# make the flow much easy to reason about.
suite "shared setup blocks" do

  subject { a + (respond_to?(:b) ? b : 0) }

  happy "when a is 5", setup: "a5", output: 5
  # happy "a5", output: 5 # if the name is the setup, use it
  happy setup: "a7", output: 7 # very concise test
  happy 'can have multiple setups', setups: ['a7', 'b3'], output: 10
  happy 'last setup wins', setups: ['a7', 'a5', 'b3'], output: 8
  happy 'input beats all setups', input: { a: 100 }, setups: ['a7', 'a5', 'b3'], output: 103

  appendix do
    setup "a5", { a: 5 }
    setup("a7") { { a: 7 } } # proc that returns a value
    setup "b3", { b: 3 }
  end
end

# Tests generally test for equality of some result returned
# from a function, but you may want to do a more complex test.
# Using an "asserts" property allows you to do any sort of
# comparison, as long as the function returns true or false.
suite "expectation blocks" do
  subject { 3 }

  happy "runs assertion block", asserts: proc { |result| result == 3 }
  happy "runs assertions (negative case)",
        asserts: proc { |result| result == 42 },
        fails:   true
  happy "block must be truthy",
        asserts: proc { |_| true }
  happy "block must be truthy (negative case)",
        asserts: proc { |_| false },
        fails:   true

end

# On some occasions you will want to check multiple values
# that should behave the same-- but you want to make sure.
# This is an "equivalence class" and can be expressed using
# the "expanded" keyword. Each entry in the expanded array
# becomes its own test. Multiple expanded values will join
# to create n*m test cases.
suite "input generators" do
  subject { i * i }

  happy inputs: { i: expanded([-1, 0, 1, 100, 1_000_000]) },
        equals: (proc { |_| i * i })

  happy 'inputs can be generated from setup blocks',
        setup:  'generate some ints',
        equals: (proc { |_| i * i })

  happy 'inputs overrides setup blocks',
        setup:  'generate some ints',
        input:  { i: 7 },
        equals: 49

  appendix do
    setup 'generate some ints',
          { i: expanded([-1, 0, 1, 100, 1_000_000]) }
  end
end

