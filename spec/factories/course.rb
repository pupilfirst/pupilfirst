FactoryBot.define do
  factory :course do
    name { Faker::Lorem.word }
    max_grade { 3 }
    pass_grade { 2 }
    grade_labels { { 1 => 'Bad', 2 => 'Good', 3 => 'Great' } }
    school { School.find_by(name: 'test') || create(:school, name: 'test') }
  end
end
