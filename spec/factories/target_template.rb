FactoryGirl.define do
  factory :target_template do
    assigner { create(:faculty) }
    days_from_start { [30, 60, 90, 180].sample }
    role { Target.valid_roles.sample }
    title { Faker::Lorem.words(4).join(' ') }
    description { Faker::Lorem.paragraph(3, 0, 3) }
    completion_instructions { Faker::Lorem.words(10).join(' ') }
  end
end
