FactoryBot.define do
  factory :founder do
    user
    cohort
    level
  end

  factory :student, class: 'Founder' do
    user
    cohort
    level
  end
end
