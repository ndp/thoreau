
# Thoreau

A more thoughtful test framework

![alt text](docs/thoreau-sample-annotated.png "Example test case using Thoreau")

## Installation

Add `gem 'thoreau'` to your application's Gemfile, or `gem install thoreau`. Neither Rails nor another test framework are required.

## Usage

Create a Ruby file. Here's an `example.rb`:

```ruby
require 'thoreau/autorun'
include Thoreau::DSL

suite "Addition regression" do
    
    testing do
        1 + 1
    end

    spec output: 2
    spec output: 3 # just to see what error detection looks like

end
```
Then, in your terminal:
```shell
$ bundle exec ruby example.rb 
INFO:   § example suite §
INFO:   ✓ spec:   (no args)
ERROR: ❓ spec:   (no args), Expected '3', but got '2'
INFO:  🛑  1 problem(s) detected.  [1 of 2 OK.]
```

## Why

### The Problem

When Kent Beck ran his first test through xUnit in the 1990s, it was a huge step forward. But since then, there's been little evolution. We have had a mild perspective
shift brought about with BDD. And we've had many incremental improvements around the edges: parallelism, mocking, seeding, hosted CI services. Cucumber/Gherkin and Gauge are great in how they provide a way to write natural language tests. Each of the several dozen tools I've used over the years have brought incremental improvements. And these tests have allowed us to create amazing and amazingly complex software systems that would have been impossible without these tools.

But the current testing frameworks continue the sequential programmatic approach introduced with the first run of a test. We use the words "spec", "be", and "describe", but under the hood we are writing more sequential code to test our production code. As systems grow, the complexity of the tests scales linearly, and it's not uncommon to see a tangle of setup blocks, hierarchies, and unclear intent. This complexity has even led to small anti-testing factions within the industry.

In the last 25 years, we've seen sequential programming wane, in favor of declarative and functional programming. These paradigms allow the developer to focus more on intent. Why not bring this to the testing world?

Thoreau is an experiment-- a proof of concept-- to imagine what it would be like if we started over and discovered TDD today, knowing what we know. The problems it attempts to address:
* As systems grow complex, developers will have trouble keeping track of exactly what they are testing with each test. Breaking open someone else's test suite should reveal the scope and breadth of the tests, and most importantly lead with what code we're testing.
* In order to deal with complexity, we've needed complex test setups, and organizing these has been ad-hoc. Setup code is found at the beginning of each spec, and then refactored out into shared setup blocks that are sometimes hard to find.
* In some tools, a whole world of helpful "matchers" is used, creating friction in writing tests. 
* Much of the code we deal with is legacy code. But the tools are created to help a developer quickly scaffold a set of regression tests for an unknown blob of code.

### Structure

* Thoreau requires the **subject** of the test to be very clear. It's written in the first block of the suite and always
  required. You can do this with other frameworks, but is optional and inconsistent. Unlike other frameworks, the
  subject _cannot_ overridden, in some nested fashion, although it can (and is) parameterized.

* Organize tests into suites with common **setups**.

Yes, `setup` and `before_each` blocks do this, but can easily lead to questions:

- which setups are running for a particular test?
- where are they?

In Thoreau, setups are always written in the appendix of the test suite. For any given test, the set-up blocks that are
run are explicitly listed by name.

### New Terminology?

* Name your test based on the type of test, eg. happy, sad, spec, edge, edges, boundary, corner, gigo, etc.
* Focus on specific tests while you develop. Like the `:focus` in some frameworks, in Thoreau, just add an exclamation
  mark, eg. `suite` to `suite!` or `spec` to `spec!`

### Less of an Ecosystem, and just a tool

Thoreau uses a dead-simple assertion language. It doesn't have one. Do we really need `.to.eql` and `.to_be.greater_than`.
  Your code under test must return a value, and you write a function that evaluates to true or false.

### Production Ready?

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

* a **clan** of tests all have the "action", or code-under-test
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
