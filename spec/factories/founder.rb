FactoryBot.define do
  factory :founder do
    user
    cohort
  end

  factory :student, class: "Founder" do
    user
    cohort
  end
end
