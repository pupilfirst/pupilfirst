FactoryGirl.define do
  factory :batch_application do
    application_round
    application_stage { create :application_stage, number: 1 }
    team_lead { create :batch_applicant, :with_user }
    college

    after(:build) do |application|
      application.batch_applicants << application.team_lead
    end

    trait :payment_requested do
      team_size { (2..10).to_a.sample }
      application_stage { create :application_stage, number: 2 }

      after(:create) do |application|
        create :payment, batch_application: application, batch_applicant: application.team_lead
      end
    end

    trait :paid do
      team_size { (2..10).to_a.sample }
      application_stage { create :application_stage, number: 3 }

      after(:create) do |application|
        create :payment, batch_application: application, batch_applicant: application.team_lead, paid_at: Time.now
      end
    end

    trait :coding_stage_submitted do
      paid

      after(:create) do |application|
        create :application_submission, :coding, batch_application: application, scored: true
      end
    end

    trait :video_stage_submitted do
      coding_stage_submitted

      before(:create) do |application|
        (application.team_size - 1).times do
          application.batch_applicants << create(:batch_applicant)
        end
      end

      after(:create) do |application|
        create :application_submission, :video, batch_application: application, scored: true
      end
    end

    trait :interview_stage do
      video_stage_submitted
      application_stage { create :application_stage, number: 5 }
    end

    trait :pre_selection_stage do
      interview_stage
      application_stage { create :application_stage, number: 6 }

      after(:create) do |application|
        create :application_submission, :interview, batch_application: application, scored: true
      end
    end

    trait :closed_stage do
      pre_selection_stage
      application_stage { create :application_stage, number: 7 }
      agreements_verified true

      after(:create) do |application|
        create :application_submission, :pre_selection, batch_application: application

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
