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
