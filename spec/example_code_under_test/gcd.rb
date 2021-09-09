def gcd(a, b)
  if (a == 0)
    return b
  end

  while b != 0
    if a > b
      a = a - b
    else
      b = b - a;
    end
  end

  return a
end
