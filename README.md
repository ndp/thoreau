# Thoreau  <img src='https://travis-ci.org/ndp/thoreau.svg?branch=master' />

A more thoughtful test framework

> Testing shows the presence, not the absence of bugs. -- Edsger W. Dijkstra

## Why?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'thoreau'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install thoreau

## Usage

TODO: Write usage instructions here

```ruby
require 'thoreau/dsl'

include Thoreau::DSL

suite "dumbist" do
  testing { true }

  happy output: true
  happy output: false # fails
  happy "descriptions if you want", output: true
end
```

## Why

The current testing frameworks are written by developers and have a sequential, programmatic approach, even though it is
sometimes obscured a bit by the words "spec" and "be". They can quickly become a tangle of setup blocks, hierarchies,
and perhaps mysterious test failures. When the first "xUnit" tool was invented, it was a huge step forward for
developers. But besides a mild perspective change with BDD, there has not been a big change in these developer tools.

We are still thinking very much step-by-step in constructing tests. But what we have learned from other programming
paradigms, like declarative and functional programming, is the value of letting go to these steps.

As an expert in testing, I've been able to level up, and use code coverage and branch/logic coverage tools to improve my
tests. But these white-box techniques are limited in the range of bugs they will find. But more importantly, the tests
themselves become complex.

Tools like Cucumber/Gauge are great that they bring us closer to the user's language, but they provide even less
structure.

> > Perhaps having more structure and constraints to our tests
> > will improve them.


Thoreau attempts to present a new paradigm, from the perspective of a tester.

### Thoreau's main features

* Organize tests into suites with common setups. Yes, setup blocks do this, but we are addressing a couple questions: (
  a) which setups are running? (b) where are they? Setups are always included in the appendix of the test suite, and
  they always must be listed with the test, by name.
* Require the "subject" of the test to be very clear. This is the first block of the suite and required. It is _not_
  overridden, although it can (and is) parameterized.
* Name your test based on the type of test, eg. happy sad spec edge edges boundary corner gigo
* Dead simple assertion language. Do we really need `.to.eql` and `.to_be.greater_than`. You just write a function that
  evaluates to true or false.
* Focus on specific tests using an exclamation point, eg. `suite!` or `spec!`

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ndp/thoreau. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Thoreau project’s codebases, issue trackers, chat rooms and mailing lists is expected to
follow the [code of conduct](https://github.com/ndp/thoreau/blob/master/CODE_OF_CONDUCT.md).


