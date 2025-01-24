FactoryBot.define do
  factory :course_author do
    transient { avoid_special_characters { false } }
    user { create(:user, avoid_special_characters: avoid_special_characters) }
    course
  end
end
