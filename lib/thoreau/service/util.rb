def combos_of(entries)
  return [{}] if entries.size == 0

  first_response = entries.first.map { |x| { x[0] => x[1] } }
  return first_response if entries.size == 1

  combos_of_rest = combos_of(entries.slice(1..(entries.size)))

  first_response.flat_map do |f|
    combos_of_rest.map { |r| r.merge(f) }
  end
end

module Thoreau
  class HashUtil

    # prop_map is a map from canonical property name to all versions
    def self.normalize_props(hash, prop_map, include_all_normalized_props = true)
      prop_map.reduce(Hash.new) do |memo, (k, v)|
        value   = one_of_these(hash, v, include_all_normalized_props ? nil : :secret_default_value)
        memo[k] = value unless value == :secret_default_value
        memo
      end
    end

    def self.one_of_these(hash, pick_one_of_these_keys, default_value = nil)
      keys_present = pick_one_of_these_keys.intersection hash.keys

      if keys_present.size > 1
        logger.error "Only of of these keys is allowed: #{keys_present.to_sentence}"
      end

      pick_one_of_these_keys.each do |k|
        return hash[k] if hash.key?(k)
      end

      default_value
    end

  end
end
