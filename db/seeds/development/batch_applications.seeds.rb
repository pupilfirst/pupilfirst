require_relative 'helper'

after 'development:application_stages', 'development:batches', 'development:batch_applicants' do
  batch = Batch.find_by(batch_number: 3)
  stage_1 = ApplicationStage.find_by number: 1
  stage_2 = ApplicationStage.find_by number: 2
  stage_3 = ApplicationStage.find_by number: 3

  registered_applicant = BatchApplicant.find_by(email: 'applicant+registered@gmail.com')
  paid_applicant = BatchApplicant.find_by(email: 'applicant+paid@gmail.com')
  submitted_applicant = BatchApplicant.find_by(email: 'applicant+submitted@gmail.com')
  interview_applicant = BatchApplicant.find_by(email: 'applicant+interview@gmail.com')

  def sample_payment
    {
      instamojo_payment_request_id: SecureRandom.hex,
      instamojo_payment_request_status: 'Pending',
      amount: 3000,
      short_url: Faker::Internet.url,
      long_url: Faker::Internet.url
    }
  end

  def create_application(applicant, application_attributes)
    application = applicant.batch_applications.create!(application_attributes)
    application.update!(team_lead: applicant)
    application
  end

  def create_payment(application)
    Payment.create!(
      sample_payment.merge(
        batch_application: application,
        batch_applicant: application.team_lead,
        paid_at: Time.now)
    )
  end

  def create_submission(application, application_stage)
    submission = ApplicationSubmission.create!(
      application_stage: application_stage,
      batch_application: application
    )

    case application_stage.number
      when 2
        urls = [
          { name: 'Code Submission', url: 'https://github.com/user/repository' },
          { name: 'Live Website', url: 'http://www.example.com' },
          { name: 'Video Submission', url: 'https://facebook.com/video' }
        ]

        urls.each do |submission_url_attributes|
          submission.application_submission_urls.create!(submission_url_attributes)
        end
      else
        raise NotImplementedError
    end
  end

  # Registered applicant
  create_application(registered_applicant, batch: batch, application_stage: stage_1)

  # Paid applicant
  paid_application = create_application(paid_applicant, batch: batch, application_stage: stage_2)
  create_payment(paid_application)

  # Submitted applicant
  submitted_application = create_application(submitted_applicant, batch: batch, application_stage: stage_2)
  create_payment(submitted_application)
  create_submission(submitted_application, stage_2)

  # Applicant promoted to interview stage
  interview_application = create_application(interview_applicant, batch: batch, application_stage: stage_3)
  create_payment(interview_application)
  create_submission(interview_application, stage_2)
end
