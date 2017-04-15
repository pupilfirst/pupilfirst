FactoryGirl.define do
  factory :founder do
    user
    name { Faker::Name.name }
    email { Faker::Internet.email }
    sequence(:phone) { |n| (9_876_543_210 + n).to_s }
    college
    reference { I18n.t('models.founder.references').sample }
  end
end
