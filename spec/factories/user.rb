FactoryBot.define do
  factory :user, aliases: %w[actor recipient] do
    transient { avoid_special_characters { false } }

    sequence(:name) do |n|
      name = "#{Faker::Name.name} #{n}"
      avoid_special_characters ? name.gsub(/[^\w\s]/, "") : name
    end

    email { Faker::Internet.email(name: name) }
    school { School.find_by(name: "test") || create(:school, :current) }
    title { Faker::Lorem.words(number: 3).join(" ") }
    time_zone { ENV["SPEC_USER_TIME_ZONE"] || "Asia/Kolkata" }

    trait :with_password do
      password { Faker::Internet.password(min_length: 8, max_length: 16) }
      password_confirmation { |user| user.password }
    end
  end
end
