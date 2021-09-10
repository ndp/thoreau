require 'thoreau/auto_run'

# This file represents a typical TDD/BDD use case.
# Starting with a spec for a function that determines
# a triangle's "type" based on the length of the three sides.
# This was an exercise in a software testing book.
#
# I generated the happy paths, and then enumerated the various
# error cases organically. After creating all the cases,
# I grouped them into separate `test_cases` blocks to give
# them an simple organization.

require_relative './example_code_under_test/triangle_type'

include Thoreau::DSL

test_suite 'triangle_type()' do

  subject { triangle_type(a, b, c) }

  test_cases 'happy paths' do
    spec 'A triangle with all equal sides is said to be an equilateral triangle.',
         inputs:  [{ a: 3, b: 3, c: 3 }, { a: 3e40, b: 3e40, c: 3e40 }],
         expects: 'equilateral'

    spec 'The scalene triangle is a type of triangle with three unequal sides.',
         input:   { a: 2, b: 3, c: 4 },
         expects: 'scalene'

    spec 'An isosceles triangle has two out of the three sides that are of the same length',
         inputs:  [{ a: 2, b: 2, c: 3 }, { a: 0.0002, b: 0.0002, c: 0.0003 }],
         expects: 'isosceles'
  end

  test_cases 'edge/boundary conditions' do
    spec 'A triangle must not be so flat as to be a straight line',
         inputs:  [{ a: 2, b: 2, c: 4 }, { a: 2, b: 3, c: 5 }],
         expects: 'error'
    spec 'A triangle must not be impossible to connect',
         input:   [{ a: 2, b: 2, c: 400 }],
         expects: 'error'

    spec 'A triangle must not have zero dimensions',
         inputs:  [{ a: 0, b: 0, c: 0 }, { a: 0, b: 1, c: 2 }, { a: 3, b: 0, c: 0 }],
         expects: 'error'
  end

  test_cases 'garbage-in/garbage-out' do
    test 'A triangle must not have negative dimensions',
         inputs:  [{ a: 3, b: 2, c: -2 }, { a: -2, b: -3, c: -4 }],
         expects: 'error'

    test 'nil sides should produce error',
         inputs: [{ a: nil, b: nil, c: 3 }, { a: 2, b: 3, c: nil }, { a: nil, b: nil, c: nil }],
         output: 'error'

    test 'non-numeric sides should produce error',
         inputs: [{ a: 'a', b: Object.new, c: 3 }, { a: 2, b: 3, c: Exception.new }],
         output: 'error'
  end
end
