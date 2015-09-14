FactoryGirl.define do
  factory :timeline_event_type do
    sample_text { Faker::Lorem.words(10).join ' ' }
    proof_required { Faker::Lorem.words(10).join ' ' }
    badge File.open(File.join(Rails.root, '/app/assets/images/seeds/timeline_event_types/default.png'))
    key { Faker::Lorem.word }
    role { Faker::Lorem.word }
    title { Faker::Lorem.words(2).join ' ' }

    factory :tet_team_formed do
      key 'team_formed'
      role 'Governance'
      title 'Team Formed'
    end

    factory :tet_new_product_deck do
      key 'new_product_deck'
      role 'Product'
      title 'New Product Deck'
      suggested_stage 'moved_to_idea_discovery'
    end

    factory :tet_one_liner do
      key 'one_liner'
      role 'Governance'
      title 'Set New One-Liner'
      suggested_stage 'moved_to_idea_discovery,moved_to_customer_validation'
    end
  end
end
