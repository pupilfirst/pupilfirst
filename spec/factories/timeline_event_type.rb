FactoryGirl.define do
  factory :timeline_event_type do
    sample_text { Faker::Lorem.words(10).join ' ' }
    proof_required { Faker::Lorem.words(10).join ' ' }
    badge File.open(File.join(Rails.root, '/spec/support/uploads/timeline_event_types/default.png'))
    key { |n| "#{Faker::Lorem.word}-#{n}" }
    role { Faker::Lorem.word }
    title { Faker::Lorem.words(2).join ' ' }

    factory :tet_registered do
      key 'registered_on_sv'
      role 'Governance'
      title 'Registered on SV.CO'
      suggested_stage 'moved_to_idea_discovery'
    end
  end
end
