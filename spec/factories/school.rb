FactoryBot.define do
  factory :school do
    name { Faker::Lorem.word }
    max_grade { 3 }
    pass_grade { 2 }
    grade_labels { { 1 => 'Bad', 2 => 'Good', 3 => 'Great' } }
  end
end
