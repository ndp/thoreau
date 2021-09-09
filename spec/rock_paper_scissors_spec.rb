require_relative './example_code_under_test/rock_paper_scissors'
require 'thoreau/auto_run'

include Thoreau::DSL

test_suite "ROCK|paper|Scissors" do

  test_cases "winners and losers" do

    subject { rock_paper_scissors(a, b) }

    happy "rock beats scissors",
          inputs: [{ a: 'rock', b: 'scissors' }, { b: 'rock', a: 'scissors' }],
          equals: :rock
    happy "scissors beats paper",
          inputs: [{ a: 'paper', b: 'scissors' }, { b: 'paper', a: 'scissors' }],
          equals: :scissors
    happy "paper beats rock",
          inputs: [{ a: 'paper', b: 'rock' }, { b: 'paper', a: 'rock' }],
          equals: :paper

    spec "symbols can be used",
         inputs: [{ a: :paper, b: :rock }],
         equals: :paper

    spec "uppercase can be used",
         inputs: [{ a: "Paper", b: "Rock" }],
         equals: :paper

  end

  test_cases "garbage inputs" do

    subject { rock_paper_scissors(a, b) }

    gigo "garbage input produces no winner",
         inputs: { a: 'dog', b: 'cat' },
         equals: '?'
  end

  test_cases "ties" do

    subject { rock_paper_scissors(a, a) } # note "a" and "a"

    happy "matching inputs tie",
          inputs: [{ a: 'rock' }, { a: 'paper' }, { a: 'scissors' }],
          equals: :tie
    happy "matching inputs tie (using expanded)",
          inputs: { a: expanded(['rock', 'paper', 'scissors']) },
          equals: :tie

  end
end


