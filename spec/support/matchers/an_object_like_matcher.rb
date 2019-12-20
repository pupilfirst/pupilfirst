module AnObjectLikeMatcher
  RSpec::Matchers.define :be_an_object_like do |expected_object|
    match do |actual_object|
      matching_results = actual_object.to_json == expected_object.to_json

      unless matching_results
        system(
          "git diff $(echo '#{JSON.pretty_generate(expected_object)}' | git hash-object -w --stdin) "\
            "$(echo '#{JSON.pretty_generate(actual_object)}' | git hash-object -w --stdin) --word-diff",
          out: $stdout,
          err: :out
        )
      end

      matching_results
    end

    failure_message { 'Look at the diff above! ^^^' }
  end
end
