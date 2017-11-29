FactoryBot.define do
  factory :state do
    initialize_with { State.where(name: name).first_or_create }
    name { Faker::Address.state }
  end
end
