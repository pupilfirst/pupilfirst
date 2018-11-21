FactoryBot.define do
  factory :level do
    # This causes factory girl to retrieve a level with given number instead of attempting to create another.
    initialize_with do
      Level.where(number: number, school: school).first_or_create
    end

    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    description { Faker::Lorem.sentence }
    number { 1 }
    school

    trait(:zero) { number { 0 } }
    trait(:one) { number { 1 } }
    trait(:two) { number { 2 } }
    trait(:three) { number { 3 } }
    trait(:four) { number { 4 } }
    trait(:five) { number { 5 } }
    trait(:six) { number { 6 } }

    trait(:sponsored) { school { create :school, sponsored: true } }
  end
end
