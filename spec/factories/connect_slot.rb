FactoryBot.define do
  factory :connect_slot do
    faculty { create :faculty }
    slot_at { 4.days.from_now }
  end
end
