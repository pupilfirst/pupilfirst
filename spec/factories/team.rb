# Todo: To be updated
FactoryBot.define do
  factory :team_with_students, class: "Team" do
    sequence(:name) do |n|
      Faker::Lorem.words(number: rand(2..3)).push(n).join(" ")
    end

    cohort

    after(:build) do |team|
      # Add two students.
      create(:student, team: team, cohort: team.cohort)
      create(:student, team: team, cohort: team.cohort)
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
