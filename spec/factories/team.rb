# Todo: To be updated
FactoryBot.define do
  factory :team_with_students, class: "Team" do
    transient { avoid_special_characters { false } }

    sequence(:name) do |n|
      name = Faker::Lorem.words(number: rand(2..3)).push(n).join(" ")
      avoid_special_characters ? name.gsub(/[^\w\s]/, "") : name
    end

    cohort

    after(:build) do |team, evaluator|
      # Add two students.
      create(
        :student,
        team: team,
        cohort: team.cohort,
        avoid_special_characters: evaluator.avoid_special_characters
      )

      create(
        :student,
        team: team,
        cohort: team.cohort,
        avoid_special_characters: evaluator.avoid_special_characters
      )
    end
  end

  # Use this factory to get an empty team.
  factory :team do
    sequence(:name) do |n|
      Faker::Lorem.words(number: rand(1..3)).push(n).join(" ")
    end
    cohort
  end
end
