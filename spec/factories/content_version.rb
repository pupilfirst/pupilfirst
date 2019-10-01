FactoryBot.define do
  factory :content_version do
    sequence(:sort_index) { |n| n }
    target
    content_block
    version_on { Date.today }

    trait :image do
      content_block { create(:content_block, :image) }
    end
    trait :file do
      content_block { create(:content_block, :file) }
    end
    trait :embed do
      content_block { create(:content_block, :embed) }
    end
    trait :markdown do
      content_block { create(:content_block, :markdown) }
    end
  end
end
