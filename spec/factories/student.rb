FactoryBot.define do
  factory :student do
    transient { avoid_special_characters { false } }
    user { create(:user, avoid_special_characters: avoid_special_characters) }
    cohort
  end
end
