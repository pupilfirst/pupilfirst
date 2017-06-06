FactoryGirl.define do
  factory :admin_user do
    fullname { Faker::Name.name }
    email { Faker::Internet.email }
    admin_type { AdminUser::TYPE_SUPERADMIN }
    user { create :user, email: email }
  end
end
