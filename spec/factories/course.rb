FactoryBot.define do
  factory :course do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(' ') }
    max_grade { 3 }
    pass_grade { 2 }
    grade_labels { { 1 => 'Bad', 2 => 'Good', 3 => 'Great' } }
    school { School.find_by(name: 'test') || create(:school, :current) }
  end
end
