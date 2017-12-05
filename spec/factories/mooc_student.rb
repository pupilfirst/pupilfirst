FactoryBot.define do
  factory :mooc_student do
    user
    email { user.email }
    college
  end
end
