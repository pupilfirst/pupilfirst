FactoryBot.define do
  factory :timeline_event_grade do
    timeline_event
    evaluation_criterion
    grade { [1, 2].sample }
  end
end
