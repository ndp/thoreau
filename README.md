
# Thoreau

A more thoughtful test framework

![Example code, annotated](docs/thoreau-sample-annotated.png "Example test case using Thoreau")

## Installation

Add `gem 'thoreau'` to your application's Gemfile, or `gem install thoreau`. Neither Rails nor another test framework are required.

## Usage

Create a Ruby file. Here's an `example.rb`:

```ruby
require 'thoreau/autorun'
include Thoreau::DSL

suite "Addition regression" do
  subject { 1 + 1 }
  spec output: 2
  spec output: 3 # just to see what error detection looks like
end
```
Then, in your terminal:
```shell
$ bundle exec ruby example.rb 
INFO:      Addition regression
INFO:   ✓  Spec       Addition regression (no args)
ERROR: ❓  Spec       Addition regression (no args)
ERROR:     Expected '3', but got '2'
INFO:  🛑  1 problem(s) detected.  [1 of 2 OK.]
```
## How it works

Thoreau dictates a stricter structure than most testing languages.  All tests should be wrapped in a  `test_suite` block. A test suite consists of:

* `subject`
* test cases
* `appendix`

### Subject

```
subject { code_under_test() }
```
Thoreau requires the **subject** of the test to be very clear. It's written in the first block of the suite and always required. It's simple: the keyword `subject` and then a block that is evaluated. 

Unlike other frameworks, the subject _cannot_ overridden, in some nested fashion, although it can (and is) parameterized. You *can* do this with other frameworks, but is optional and inconsistent. 

### Test Case

```
spec 'a test', inputs: { i: 5 }, equals: { 15 }, setup: 'when i is 1'
```
Each test case consists of:
* a keyword `spec`, followed by 
* a name
* `inputs`, which provide a way to parameterize the test. This is an hash and all its properties will be exposed to `subject` block. It can also be a block that returns a hash. If it's not needed, it can be omitted.
* `equals` is a value (or block that returns a value) that must match the return value of `subject`. If this is a block, it is provided the same context as the `subject` block (all the inputs). Every test should have an `equals` (unless it has an assert).
* If `equals` is insufficient, `assert` may be used. It is a block that returns `true` for success, or false for an error detected
* Finally, if the test is going to raise an exception, specify it with a `raises`.
* `setups` are a way to share setup blocks between test cases. This is a name of one or more setups found in the appendix. 

#### Appendix
```
appendix do
  setup 'when i is 1', { i: 1 }
  setup 'when i is 2', { i: 2 }
end
```
In Thoreau, `setups` are always written in the appendix of the test suite. For any given test, the set-up blocks that are run are explicitly listed by name. 

A setup block itself can be either a hash with specific values or a block that returns such a thing. 

Setup blocks and input blocks are run in the same context, but setup blocks are run first.

### Legacy Tests

TBD

### Expanded Setup Values

TBD

#### Pending / Fails

TBD

### Focus on a single test

**Focus** on specific tests while you develop. Equivalent to the `:focus` in some frameworks, in Thoreau, just add an exclamation mark, eg. `suite` to `suite!` or `spec` to `spec!`

### Alternatives

Thoreau does support one alternate structure, where you need different subjects:
* `test_cases <name> do`
  - subject
  - tests
* `test_cases <name> do`
  - subject
  - tests
  ...
* appendix

**Flexibility.** Name your test based on the type of test, eg. happy, sad, spec, edge, edges, boundary, corner, gigo, etc.

## Motivation

### The Problem

When Kent Beck ran his first unit test in the 1990s, it was a huge step forward. And since then, xUnit has evolved. We've improved parallelism, mocking, seeding. We've added hosted CI services. We have had a mild perspective shift brought about with BDD. Cucumber/Gherkin and Gauge teased us that product managers would write tests in natural languages (for us).  And backed up by these millions of tests, we've been able to create amazing (and amazingly complex) software that would have been impossible without them.

But the current testing frameworks and their tests are much like the code we wrote in the 1990s. We continue the sequential programmatic approach introduced with the first test run. We use the words "spec", "be", and "describe", but under the hood we are writing sequential code to test our production code. This was okay at first, but as systems grow, the complexity of the tests scales linearly, and it's not uncommon to see a tangle of setup blocks, hierarchies, and unclear intent. This complexity has even led to small anti-testing factions within the industry. In the last 25 years, we've seen sequential programming wane, in favor of declarative and functional programming. These paradigms allow the developer to write more concise code and focus more on intent. Why not bring this to the testing world?

Thoreau is an experiment-- a proof of concept-- to imagine what it would be like if we started over and discovered TDD today, knowing what we know. 

The problems Thoreau strives to address:

#### Gnarled Test Suites

As test suites evolve with a complex systems, so do test suites. Adding new features requires new tests. Setup code grows complicated,  gets moved to other files, and tests become opaque. Refactoring of tests is certainly possible, but less popular than refactoring production code (and ideally done with no production code modifications), so tests will have outdated test cases that make reading them difficult. Developers have trouble understanding what a test suite is and isn't testing.  Useful regression tests may employ the language of its original system, obsolete by modern standards. But it's not uncommon to hear, "what exactly is this testing?". Ideally, breaking open someone else's test suite should immediately reveal the scope and breadth of the tests. 

#### Test Tool Friction

It's natural that the tools evolved from a single `assert` to dozens or hundreds of matchers. These are indeed helpful, but until they are mastered, they can take focus from the actual testing process. They can encourage complex tests, and in some cases can make reading a test suite less approachable. And for historical reasons, some tools offer two or three different syntaxes for tests, adding more complexity, if not to the tests, to the documentation. One of the goals of a new testing tool should be to keep the surface area as small as possible. [I'm not 100% confident in this goal... maybe it'll be axed. – ed]

#### Acknowledgement of Legacy Code

Much of the code we deal with is legacy code. The simplest definition of legacy code is: code without tests. This situation requires a different workflow than TDD: you want to quickly build a safety net of regression tests before taking a wack at refactoring or improving the legacy code. What would a tool look like that facilitates this flow?

#### Living Code

Tests suites live with and evolve with the production code, but most test tools assume each test run independently. There are separate tools (especially related to CI) that track performance of test suites over time. This could simply be part of the test tool itself. [nothing is done on this front yet]

## Production Ready?

This project is a place to discover and try out new techniques. It's a "proof of concept". Although I'll do what I can
to make it solid, right now it's flexible so the ideas can be evaluated easily. The DSL can certainly evolve, and in
fact, that's really the point.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Terminology

(Test) Case ∈ (Test) Family ∈ (Test) Clan ∈ (Test) Suite

* a **clan** of tests all have the subject, or code-under-test
* a **family** of tests all have the same setups and expections, but have different inputs. Commonly known as an *equivalence class*.
* a **case** is a single combination of setups, inputs and executions that either is detects or does not detect a problem.

Note: we avoid using the words pass, bug, error. "

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ndp/thoreau. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Thoreau project’s codebases, issue trackers, chat rooms and mailing lists is expected to
follow the [code of conduct](https://github.com/ndp/thoreau/blob/master/CODE_OF_CONDUCT.md).

## Credits

* Woodcut Image: Grindall Reynolds, CC BY-SA 4.0 <https://creativecommons.org/licenses/by-sa/4.0>, via Wikimedia Commons


## le archive

> Testing shows the presence, not the absence of bugs. -- Edsger W. Dijkstra
