FactoryGirl.define do
  factory :mooc_student do
    user
    email { user.email }
  end
end
