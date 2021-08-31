# Thoreau  <img src='https://travis-ci.org/ndp/thoreau.svg?branch=master' />


A more thoughtful test framework

> Testing shows the presence, not the absence of bugs. -- Edsger W. Dijkstra
  


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
require 'thoreau/v2/dsl'

include Thoreau::V2::DSL

suite "dumbist" do
  testing { true }

  happy output: true
  happy output: false # fails
  happy "descriptions if you want", output: true
end
```

## Why
For data-driven or black-box testing, two things are important:
- easily provide a range of inputs
- identify and utilize "equivalence classes" of data
Our current testing frameworks do nothing to support this.

The current testing frameworks are written by developers and have a 
sequential, programmatic approach, even though it is sometimes obscured
a bit by the words "spec" and "be". We are still thinking very
much step-by-step in constructing tests. But what we have learned from
other programming paradigms, like declarative and functional programming,
is the value of letting go to these steps.

Thoreau attempts to present a new paradigm, from the perspective of
a tester.

As an expert in testing, I've been able to level up, and use code coverage
and branch/logic coverage tools to improve my tests. But these white-box
techniques are limited in the range of bugs they will find, and 

## Features:
* organize tests into suites with common setups and subject
* name your test based on the type of test, eg. happy sad spec edge edges boundary corner gigo
* simple assertions written in nature Ruby code (you write them yourself).
* focus on specific tests using an exclamation point, eg. `suite!` or `spec!`



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ndp/thoreau. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Thoreau project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ndp/thoreau/blob/master/CODE_OF_CONDUCT.md).


