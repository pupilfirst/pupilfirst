FactoryGirl.define do
  factory :target_group do
    name { Faker::Lorem.word }
    program_week
    sequence(:sort_index) { |n| n }
    description { Faker::Lorem.sentence }

    transient do
      batch nil
      week_number nil
    end

    after(:create) do |target_group, evaluator|
      target_group.program_week.update!(batch: evaluator.batch) if evaluator.batch.present?
      target_group.program_week.update!(number: evaluator.week_number) if evaluator.week_number.present?
    end
  end
end
