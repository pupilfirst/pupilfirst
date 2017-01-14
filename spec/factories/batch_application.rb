FactoryGirl.define do
  factory :batch_application do
    batch
    application_stage { create :application_stage, number: 1 }
    team_lead { create :batch_applicant, :with_user }
    college

    after(:build) do |application|
      application.batch_applicants << application.team_lead
    end

    trait :payment_requested do
      team_size { (2..10).to_a.sample }

      after(:create) do |application|
        create :payment, batch_application: application, batch_applicant: application.team_lead
      end
    end

    trait :paid do
      team_size { (2..10).to_a.sample }
      application_stage { create :application_stage, number: 2 }

      after(:create) do |application|
        create :payment, batch_application: application, batch_applicant: application.team_lead, paid_at: Time.now
      end
    end

    trait :stage_2_submitted do
      paid

      after(:create) do |application|
        (application.team_size - 1).times do
          application.batch_applicants << create(:batch_applicant)
        end

        create :application_submission, :stage_2_submission, batch_application: application, scored: true
      end
    end

    trait :stage_3 do
      stage_2_submitted
      application_stage { create :application_stage, number: 3 }
    end

    trait :stage_4 do
      stage_3
      application_stage { create :application_stage, number: 4 }

      after(:create) do |application|
        create :application_submission, :stage_3_submission, batch_application: application, scored: true
      end
    end

    trait :stage_5 do
      stage_4
      application_stage { create :application_stage, number: 5 }
      agreements_verified true

      after(:create) do |application|
        create :application_submission, :stage_4, batch_application: application

        image_path = File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg'))
        address = [Faker::Address.street_address, Faker::Address.city, Faker::Address.zip].join("\n")

        # Add extra info to applicants
        application.batch_applicants.each do |applicant|
          applicant.update!(
            fee_payment_method: BatchApplicant::PAYMENT_METHOD_REGULAR_FEE,
            role: Founder.valid_roles.sample,
            gender: Founder.valid_gender_values.sample,
            born_on: Date.parse('1990-01-01'),
            parent_name: Faker::Name.name,
            permanent_address: address,
            address_proof: File.open(image_path),
            current_address: address,
            phone: (9_876_000_000 + rand(999_999)).to_s,
            id_proof_type: BatchApplicant::ID_PROOF_TYPES.sample,
            id_proof_number: Faker::Internet.password,
            id_proof: File.open(image_path)
          )
        end
      end
    end
  end
end
