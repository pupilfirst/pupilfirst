FactoryBot.define do
  factory :admin_user do
    fullname { Faker::Name.name }
    admin_type { AdminUser::TYPE_SUPERADMIN }
    email { Faker::Internet.email(fullname) }
  end
end
