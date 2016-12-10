FactoryGirl.define do
  factory :program_week do
    name { Faker::Lorem.word }
    sequence(:number) { |n| n + 1 }
    batch
    icon_name { ProgramWeek.icon_name_options.sample }
  end
end
