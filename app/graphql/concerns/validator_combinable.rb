module ValidatorCombinable
  def combine(*responses)
    failures = responses - [nil]

    return if (failures).empty?

    failures.join(', ')
  end
end
