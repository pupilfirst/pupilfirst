# This will guess the User class
FactoryGirl.define do
  factory :user do
    fullname "John Doe"
    username  "Doe"
    email 		"foo@bar.com"
  end
end
