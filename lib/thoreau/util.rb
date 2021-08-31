def combos_of(entries)
  return [{}] if entries.size == 0

  first_response = entries.first.map { |x| { x[0] => x[1] } }
  return first_response if entries.size == 1

  combos_of_rest = combos_of(entries.slice(1..(entries.size)))

  first_response.flat_map do |f|
    combos_of_rest.map { |r| r.merge(f) }
  end
end
