FactoryBot.define do
  factory :reaction do
    user
    reaction_value { "😀" }

    association :reactionable, factory: :timeline_event
  end
end
