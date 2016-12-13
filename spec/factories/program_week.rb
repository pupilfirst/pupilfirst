FactoryGirl.define do
  factory :program_week do
    name { Faker::Lorem.word }
    sequence(:number)
    batch
    icon_name { ProgramWeek.icon_name_options.sample }
  end
end
