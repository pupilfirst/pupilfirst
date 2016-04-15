FactoryGirl.define do
  factory :target do
    role { Target.valid_roles.sample }
    assigner { create :faculty }

    # The assignee can be a founder or a startup, depending on role.
    assignee do
      startup = create :startup

      if role == Target::ROLE_FOUNDER
        startup.founders.first
      else
        startup
      end
    end

    status { 'pending' }
    title { Faker::Lorem.words(6).join ' ' }
    description { Faker::Lorem.words(200).join ' ' }
  end
end
