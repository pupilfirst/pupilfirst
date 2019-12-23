FactoryBot.define do
  factory :evaluation_criterion do
    sequence(:name) { |i| (Faker::Lorem.words(2) + [i.to_s]).join(' ') }
    description { Faker::Lorem.sentence }
    max_grade { 3 }
    pass_grade { 2 }
    grade_labels { { 1 => 'Bad', 2 => 'Good', 3 => 'Great' } }
  end
end
