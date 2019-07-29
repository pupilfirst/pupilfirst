FactoryBot.define do
  factory :faculty do
    user
    category { Faculty::CATEGORY_VR_COACHES }
  end
end
