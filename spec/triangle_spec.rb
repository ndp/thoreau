require 'thoreau'

include Thoreau::V2::DSL

def triangle_type(a, b, c)
  return 'error' unless a.is_a?(Numeric)
  return 'error' unless b.is_a?(Numeric)
  return 'error' unless c.is_a?(Numeric)
  return 'error' if a <= 0
  return 'error' if b <= 0
  return 'error' if c <= 0
  return 'equilateral' if a == b && b == c
  return 'error' if (a + b) < c
  return 'error' if (a + c) < b
  return 'error' if (b + c) < a
  return 'isosceles' if a == b || b == c || a == c
  'scalene'
end

test_suite 'triangle type' do

  testing { triangle_type(a, b, c) }

  spec 'A triangle with all equal sides is said to be an equilateral triangle.',
       input:   [{ a: 3, b: 3, c: 3 }, { a: 3e40, b: 3e40, c: 3e40 }],
       expects: 'equilateral'
  spec 'The scalene triangle is a type of triangle with three unequal sides.',
       input:   { a: 2, b: 3, c: 4 },
       expects: 'scalene'
  spec 'An isosceles triangle has two out of the three sides that are of the same length',
       input: [{ a: 2, b: 2, c: 3 }, { a: 0.0002, b: 0.0002, c: 0.0003 }], expects: 'isosceles'

  spec 'A triangle must not be so flat as to be a straight line',
       input: [{ a: 2, b: 2, c: 4 }, { a: 2, b: 3, c: 5 }], expects: 'error'
  spec 'A triangle must not be impossible to connect',
       input: [{ a: 2, b: 2, c: 400 }], expects: 'error'

  spec 'A triangle must not have zero dimensions',
       input: [{ a: 0, b: 1, c: 2 }, { a: 0, b: 0, c: 0 }, { a: 3, b: 0, c: 0 }], expects: 'error'
  spec 'A triangle must not have negative dimensions',
       input:   [{ a: 3, b: 2, c: -2 }, { a: -2, b: -3, c: -4 }],
       expects: 'error'
  spec 'nil sides should produce error',
       input:   [{ a: nil, b: nil, c: 3 }, { a: 2, b: 3, c: nil }, {}],
       output: 'error'
  spec 'non-numeric sides should produce error',
       input:   [{ a: 'a', b: Object.new, c: 3 }, { a: 2, b: 3, c: Exception.new }],
       output: 'error'
end
