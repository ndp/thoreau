require 'thoreau/auto_run'
include Thoreau::DSL

# This idea is that this is some weird legacy code
# that you don't understand.
def weirdass_legacy_code(a, b, c)
  return 'b' if a < -10000
  return 'bc' if a > 10001
  if c == 8 && b < 0 || a < 0
    "negate"
  end
  return 'all the same' if a == b && b == c

end

# Backfilling tests is as easy as enumerating inputs
# The "legacy" keyword kicks-in snapshot code that
# records test results, similar to snapshots or VCR
# recordings. What is saved, though, is simple, and
# matches outputs/exceptions thrown.
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
