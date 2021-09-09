require 'thoreau'

include Thoreau::DSL

# A test suite has a title
suite "simplest tests" do
  testing do
    # This is some code that is run for each test
    # It's the "subject" of the test suite. In this
    # case we just return "true" to get things moving.
    true
  end

  happy "output matches result of test block", output: true
  happy "output equals result of test block", equals: true # same thing

  # If tests don't work, just mark them with "fails" or "pending" and the will be "OK"
  happy "tests marked 'fails' must fail", output: false, fails: true
  happy "tests marked 'pending' must fail", output: false, pending: true

  happy "tests can have doescriptions", output: true
  happy output: true # or not
end

suite 'nested tests' do

  test_cases 'simple nesting' do
    subject { 1 }

    happy equals: 1
  end

  test_cases 'using setup from the appendix' do
    subject { i }

    happy equals: 2, setup: 'two'
  end

  appendix do
    setup 'two', { i: 2 }
  end

end

suite 'nested tests 2' do
  subject { 'only one' }

  test 'simple test', expects: 'only one'

  test_cases do
    subject { 'is allowed' }
    test 'suite produces error', expects: 'is allowed'
  end
end

suite "exceptions" do
  testing { raise "poopy butt" }

  sad raises: "poopy butt"
  sad raises: "poopy butts spelt wrong", fails: true
  sad "wrong exception type", raises: Exception, fails: true
end

suite "parameter" do
  testing { a }

  happy "input parameter passes to test block", input: { a: 5 }, output: 5
  happy "'input' can have an 's' for readability", inputs: { a: 5, b: 9 }, output: 5
end

suite "multiple parameters" do
  testing { a + b }

  happy 'receives both params', inputs: { a: 1, b: 3 }, equals: 4
  happy 'raises if missing a parameter',
        inputs: { a: 2 }, fails: true
  happy 'extra params are ignored', input: { a: 5, b: 7, z: "ignored" }, output: 12
end

suite "shared setup blocks" do
  testing { a + (respond_to?(:b) ? b : 0) }

  happy "when a is 5", setup: "a5", output: 5
  # happy "a5", output: 5 # if the name is the setup, use it
  happy setup: "a7", output: 7 # very concise test
  happy 'can have multiple setups', setups: ['a7', 'b3'], output: 10
  happy 'last setup wins', setups: ['a7', 'a5', 'b3'], output: 8
  happy 'input beats all setups', input: {a: 100}, setups: ['a7', 'a5', 'b3'], output: 103

  appendix do
    setup "a5", { a: 5 }
    setup("a7") { { a: 7 } } # proc that returns a value
    setup "b3", { b: 3 }
  end
end

suite "expectation blocks" do
  testing { 3 }

  happy "runs assertion block", asserts: proc { |result| result == 3 }
  happy "runs assertions (negative case)", asserts: proc { |result| result == 42 }, fails: true
  happy "block must be truthy", asserts: proc { |_| true }
  happy "block must be truthy (negative case)", asserts: proc { |_| false }, fails: true

  happy "tests equivalence of proc result", equals: proc { 3 }
  happy "tests equivalence of proc result (negative case)",
        equals: proc { 5 },
        fails:  true
end

suite "input generators" do
  testing { i * i }

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

suite 'appendix' do

  appendix do
    # inputs # what are the inputs we care about
    #
    # setups # what are commend set-up scenarios
    #
    # outputs # what are the outputs we care about
    #
    # expectations
  end

end
