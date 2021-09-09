def triangle_type(a, b, c)
  return 'error' unless a.is_a?(Numeric)
  return 'error' unless b.is_a?(Numeric)
  return 'error' unless c.is_a?(Numeric)
  return 'error' if a <= 0
  return 'error' if b <= 0
  return 'error' if c <= 0
  return 'equilateral' if a == b && b == c
  return 'error' if (a + b) <= c
  return 'error' if (a + c) <= b
  return 'error' if (b + c) <= a
  return 'isosceles' if a == b || b == c || a == c
  'scalene'
end
