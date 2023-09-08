FactoryBot.define do
  factory :school_admin do
    transient { school { nil } }
    after(:build) do |school_admin, evaluator|
      user =
        evaluator.user ||
          (
            if evaluator.school.present?
              FactoryBot.create(:user, school: evaluator.school)
            else
              FactoryBot.create(:user)
            end
          )
      school_admin.user = user
    end
  end
end
