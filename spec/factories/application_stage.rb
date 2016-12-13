FactoryGirl.define do
  factory :application_stage do
    # The following statement causes factory girl to retrieve a stage with given number instead of attempting
    # to create another. It'll still rewrite the name, though - shouldn't be a problem.
    initialize_with { ApplicationStage.where(number: number).first_or_create }

    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    sequence(:number) { |n| n }
    final_stage { number == 5 ? true : false }
  end
end
