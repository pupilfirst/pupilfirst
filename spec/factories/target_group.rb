FactoryGirl.define do
  factory :target_group do
    name { Faker::Lorem.word }
    program_week
    sequence(:number) { |n| n + 1 }
    description { Faker::Lorem.sentence }

    transient do
      batch nil
    end

    after(:create) do |target_group, evaluator|
      target_group.program_week.update!(batch: evaluator.batch) if evaluator.batch.present?
    end
  end
end
