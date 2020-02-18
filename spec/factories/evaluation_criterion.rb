FactoryBot.define do
  factory :evaluation_criterion do
    sequence(:name) { |i| (Faker::Lorem.words(number: 2) + [i.to_s]).join(' ') }
    max_grade { 3 }
    pass_grade { 2 }
    grade_labels { [{ 'grade' => 1, 'label' => 'Bad' }, { 'grade' => 2, 'label' => 'Good' }, { 'grade' => 3, 'label' => 'Great' }] }
  end
end
