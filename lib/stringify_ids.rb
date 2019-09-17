module StringifyIds
  def stringify_ids(hash)
    hash.keys.each_with_object({}) do |key, result|
      string_key = key.to_s
      original_value = hash[key]

      result[key] = if original_value.is_a?(Array)
        stringify_ids_in_array(string_key, original_value)
      elsif original_value.respond_to?(:key?)
        stringify_ids(original_value)
      elsif (string_key == 'id' || string_key.ends_with?('_id')) && original_value.is_a?(Numeric)
        original_value.to_s
      else
        original_value
      end
    end
  end

  private

  def stringify_ids_in_array(key, array)
    if key.ends_with?('_ids')
      array.map(&:to_s)
    else
      array.map do |element|
        if element.respond_to?(:key?)
          stringify_ids(element)
        else
          element
        end
      end
    end
  end
end
