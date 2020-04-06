module AnObjectLikeMatcher
  RSpec::Matchers.define :be_an_object_like do |expected_object|
    match do |actual_object|
      actual_object.to_json == expected_object.to_json
    end

    failure_message do |actual_object|
      "Mismatch between expected object and actual object:\n\n" +
        Diffy::Diff.new(
          JSON.pretty_generate(expected_object),
          JSON.pretty_generate(actual_object)
        ).to_s(:text)
    end
  end
end
