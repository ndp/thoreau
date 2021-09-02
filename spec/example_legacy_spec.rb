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

  spec input: { a: -10000, b: -10, c: 8 }, expected: legacy_values('abc')
  spec input: { a: -20000, b: -10, c: 8 }, expected: legacy_values('abc2')

end
