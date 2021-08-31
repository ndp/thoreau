require 'thoreau'

include Thoreau::V2::DSL

def rock_paper_scissors(a, b)
  return :tie if a == b
  case [a,b].sort.join(' ').downcase
  when 'paper rock'
    :paper
  when 'paper scissors'
    :scissors
  when 'rock scissors'
    :rock
  else
    '?'
  end
end

test_suite "winners and losers" do

  subject { rock_paper_scissors(a, b) }

  happy "rock beats scissors",
        inputs: [{ a: 'rock', b: 'scissors' },{ b: 'rock', a: 'scissors' }],
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

  gigo "garbage input produces no winner",
       inputs: {a: 'dog', b: 'cat' },
       equals: '?'

end

test_suite "matching values" do
  subject { rock_paper_scissors(a, a) } # note "a" and "a"

  happy "matching inputs tie",
        inputs: [{ a: 'rock' }, { a: 'paper' }, { a: 'scissors' }],
        equals: :tie
  happy "matchig inputs tie (enumerator)",
        inputs: { a: Enumerator.new(['rock', 'paper', 'scissors']) },
        equals: :tie
end

