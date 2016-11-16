require_relative 'helper'

after 'development:application_stages', 'development:batches', 'development:batch_applicants', 'admin_users' do
  puts 'Seeding batch_applications'

  applications_batch = Batch.find_by(batch_number: 5)
  interview_batch = Batch.find_by(batch_number: 4)
  pre_selection_batch = Batch.find_by(batch_number: 3)

  stage_1 = ApplicationStage.find_by number: 1
  stage_2 = ApplicationStage.find_by number: 2
  stage_3 = ApplicationStage.find_by number: 3
  stage_4 = ApplicationStage.find_by number: 4

  registered_applicant = BatchApplicant.find_by(email: 'applicant+registered@gmail.com')
  paid_applicant = BatchApplicant.find_by(email: 'applicant+paid@gmail.com')
  submitted_applicant = BatchApplicant.find_by(email: 'applicant+submitted@gmail.com')
  submitted_rejected_applicant = BatchApplicant.find_by(email: 'applicant+submitted+rejected@gmail.com')
  interview_applicant = BatchApplicant.find_by(email: 'applicant+interview@gmail.com')
  interview_rejected_applicant = BatchApplicant.find_by(email: 'applicant+interview+rejected@gmail.com')
  pre_selection_applicant = BatchApplicant.find_by(email: 'applicant+pre_selection@gmail.com')
  co_applicant = BatchApplicant.find_by(email: 'coapplicant+pre_selection@gmail.com')

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
        create_submission_urls(submission)
      when 3
        submission.update!(score: rand(100))
      else
        raise NotImplementedError
    end

    submission
  end

  def create_submission_urls(submission)
    urls = [
      { name: 'Code Submission', url: 'https://github.com/user/repository' },
      { name: 'Live Website', url: 'http://www.example.com' },
      { name: 'Video Submission', url: 'https://facebook.com/video' }
    ]

    urls.map do |submission_url_attributes|
      submission.application_submission_urls.create!(submission_url_attributes)
    end
  end

  def score_stage_2_submission(submission, score: 70)
    submission.application_submission_urls.each do |url|
      url.update!(score: score, admin_user: AdminUser.first) if url.name =~ /Submission/
    end
  end

  # Registered applicant
  create_application(registered_applicant, batch: applications_batch, application_stage: stage_1)

  # Paid applicant
  paid_application = create_application(paid_applicant, batch: applications_batch, application_stage: stage_2)
  create_payment(paid_application)

  # Submitted applicant
  submitted_application = create_application(submitted_applicant, batch: applications_batch, application_stage: stage_2)
  create_payment(submitted_application)
  create_submission(submitted_application, stage_2)

  # Submitted and rejected applicant
  submitted_rejected_application = create_application(submitted_rejected_applicant, batch: interview_batch, application_stage: stage_2)
  create_payment(submitted_rejected_application)
  submission = create_submission(submitted_rejected_application, stage_2)
  score_stage_2_submission(submission, score: 40)

  # Applicant promoted to interview stage
  interview_application = create_application(interview_applicant, batch: interview_batch, application_stage: stage_3)
  create_payment(interview_application)
  submission = create_submission(interview_application, stage_2)
  score_stage_2_submission(submission)

  # Applicant rejected at interview stage
  interview_rejected_application = create_application(interview_rejected_applicant, batch: pre_selection_batch, application_stage: stage_3)
  create_payment(interview_rejected_application)
  submission = create_submission(interview_rejected_application, stage_2)
  score_stage_2_submission(submission)
  submission = create_submission(interview_rejected_application, stage_3)
  submission.update!(feedback_for_team: 'This is the reason why you were rejected, stored in the feedback_for_team field.')

  # Application at pre-selection stage
  pre_selection_application = create_application(pre_selection_applicant, batch: pre_selection_batch, application_stage: stage_4)
  create_payment(pre_selection_application)
  submission = create_submission(pre_selection_application, stage_2)
  score_stage_2_submission(submission)
  create_submission(pre_selection_application, stage_3)
  pre_selection_application.batch_applicants << co_applicant
end
