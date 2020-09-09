FactoryBot.define do
  factory :audit_record do
    school

    trait :add_school_admin do
      audit_type { AuditRecord::TYPE_ADD_SCHOOL_ADMIN }
      metadata { { user_id: rand(1..1000), email: Faker::Internet.email } }
    end
  end
end
