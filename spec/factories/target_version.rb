FactoryBot.define do
  factory :target_version do
    target
    version_at { Time.zone.now }
  end
end
