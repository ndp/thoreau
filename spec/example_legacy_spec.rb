require 'thoreau'
include Thoreau::DSL

def weirdass_legacy_code(a, b, c)
  return 'b' if a < -10000
  return 'bc' if a > 10001
  if c == 8 && b < 0 || a < 0
    "negate"
  end
  return 'all the same' if a == b && b == c

end

suite "legacy testing" do
  testing { weirdass_legacy_code(a, b, c) }

  legacy input: { a: -10000, b: -10, c: 8 }
  legacy input: { a: -20000, b: -10, c: 8 }
  legacy input: { a: 10001, b: -10, c: 8 }
  legacy input: { a: 10002, b: -10, c: 8 }
  legacy input: { a: 0, b: 0, c: 8 }
  legacy input: { a: 0, b: -1, c: 8 }
  legacy input: { a: -1, b: -1, c: 8 }
  legacy input: { a: -1, b: 0, c: 8 }
  legacy input: { a: 7, b: 7, c: 7 }
  legacy input: { a: 7, b: 7, c: 8 }

end
