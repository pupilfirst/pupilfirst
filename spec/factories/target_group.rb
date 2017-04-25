FactoryGirl.define do
  factory :target_group do
    name { Faker::Lorem.word }
    sequence(:sort_index)
    description { Faker::Lorem.sentence }
    level

    # transient do
    #   batch nil
    #   week_number nil
    # end
    #
    # after(:create) do |target_group, evaluator|
    #   target_group.program_week.update!(batch: evaluator.batch) if evaluator.batch.present?
    #   target_group.program_week.update!(number: evaluator.week_number) if evaluator.week_number.present?
    # end
  end
end
