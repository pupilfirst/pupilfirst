FactoryGirl.define do
  factory :connect_slot do
    faculty
    slot_at { 4.days.from_now }
  end
end
