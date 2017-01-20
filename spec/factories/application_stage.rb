FactoryGirl.define do
  factory :application_stage do
    # The following statement causes factory girl to retrieve a stage with given number instead of attempting
    # to create another. It'll still rewrite the name, though - shouldn't be a problem.
    initialize_with { ApplicationStage.where(number: number).first_or_create }

    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    sequence(:number)
    final_stage { number == 7 ? true : false }

    trait(:screening) do
      number 1
      name 'Screening'
    end

    trait(:payment) do
      number 2
      name 'Payment'
    end

    trait(:coding) do
      number 3
      name 'Coding'
    end

    trait(:video) do
      number 4
      name 'Video'
    end

    trait(:interview) do
      number 5
      name 'Interview'
    end

    trait(:pre_selection) do
      number 6
      name 'Pre-selection'
    end

    trait(:closed) do
      number 7
      name 'Closed'
    end
  end
end
