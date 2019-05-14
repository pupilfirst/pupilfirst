module CamelizeKeys
  def camelize_keys(hash)
    hash.deep_transform_keys { |k| k.to_s.camelize(:lower) }
  end
end
