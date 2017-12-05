FactoryBot.define do
  factory :connect_slot do
    faculty { create :faculty, :connectable }
    slot_at { 4.days.from_now }
  end
end
