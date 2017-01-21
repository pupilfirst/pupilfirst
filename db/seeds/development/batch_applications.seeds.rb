require_relative 'helper'

after 'development:application_stages', 'development:batch_applicants', 'admin_users', 'development:application_rounds' do
  puts 'Seeding batch_applications'

  batch = Batch.find_by(batch_number: 3)
  application_rounds = ApplicationRound.where(batch: batch)

  round_in_applications = application_rounds.find_by number: 4 # Round accepting applications.
  round_in_video = application_rounds.find_by number: 3 # Round in video stage.
  round_in_interview = application_rounds.find_by number: 2 # Round in interview stage.
  round_in_pre_selection = application_rounds.find_by number: 1 # Round in pre-selection stage.

  stage_1 = ApplicationStage.initial_stage
  stage_2 = ApplicationStage.find_by(number: 2)
  stage_3 = ApplicationStage.find_by(number: 3)
  stage_4 = ApplicationStage.find_by(number: 4)
  stage_5 = ApplicationStage.find_by(number: 5)
  stage_6 = ApplicationStage.find_by(number: 6)
  stage_7 = ApplicationStage.final_stage

  registered_applicant = BatchApplicant.find_by(email: 'applicant+registered@gmail.com')
  paid_applicant = BatchApplicant.find_by(email: 'applicant+paid@gmail.com')
  video_applicant = BatchApplicant.find_by(email: 'applicant+video@gmail.com')
  interview_applicant = BatchApplicant.find_by(email: 'applicant+interview@gmail.com')
  interview_co_applicant = BatchApplicant.find_by(email: 'coapplicant+interview@gmail.com')
  pre_selection_applicant = BatchApplicant.find_by(email: 'applicant+pre_selection@gmail.com')
  pre_selection_co_applicant = BatchApplicant.find_by(email: 'coapplicant+pre_selection@gmail.com')
  closed_applicant = BatchApplicant.find_by(email: 'applicant+closed@gmail.com')
  closed_co_applicant = BatchApplicant.find_by(email: 'coapplicant+closed@gmail.com')

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
      when 3 # Coding
        create_submission_urls(:coding, submission)
        application.update!(generate_certificate: true)
      when 4 # Video
        create_submission_urls(:video, submission)
      when 5 # Interview
        submission.update!(score: rand(100))
      when 6 # Pre-selection
        submission.update!(notes: 'This is a seeded submission for stage 6.')
      else
        raise NotImplementedError
    end

    submission
  end

  def create_submission_urls(type, submission)
    urls = case (type)
      when :coding
        [
          { name: 'Code Submission', url: 'https://github.com/user/repository' },
          { name: 'Live Website', url: 'http://www.example.com' }
        ]
      when :video
        [{ name: 'Video Submission', url: 'https://facebook.com/video' }]
      else
        raise NotImplementedError, "Cannot create submission URL-s for type #{type}"
    end

    urls.map do |submission_url_attributes|
      submission.application_submission_urls.create!(submission_url_attributes)
    end
  end

  def score_submission(type, submission, score: 70)
    if [:coding, :video].include?(type)
      submission.application_submission_urls.each do |url|
        url.update!(score: score, admin_user: AdminUser.first) if url.name =~ /Submission/
      end
    else
      raise NotImplementedError, "Cannot score submission for type #{type}"
    end
  end

  # Registered applicant
  create_application(registered_applicant, application_round: round_in_applications, application_stage: stage_1)

  # Applicant who has paid.
  paid_application = create_application(paid_applicant, application_round: round_in_applications, application_stage: stage_3)
  create_payment(paid_application)

  # Applicant at video stage.
  coding_application = create_application(video_applicant, application_round: round_in_video, application_stage: stage_4)
  create_payment(coding_application)
  submission = create_submission(coding_application, stage_3)
  score_submission(:coding, submission)

  # Applicant at interview stage.
  interview_application = create_application(interview_applicant, application_round: round_in_interview, application_stage: stage_5)
  create_payment(interview_application)
  submission = create_submission(interview_application, stage_3)
  score_submission(:coding, submission)
  interview_application.batch_applicants << interview_co_applicant
  submission = create_submission(interview_application, stage_4)
  score_submission(:video, submission)

  # Applicant at pre-selection stage.
  pre_selection_application = create_application(pre_selection_applicant, application_round: round_in_pre_selection, application_stage: stage_6)
  create_payment(pre_selection_application)
  submission = create_submission(pre_selection_application, stage_3)
  score_submission(:coding, submission)
  pre_selection_application.batch_applicants << pre_selection_co_applicant
  submission = create_submission(pre_selection_application, stage_4)
  score_submission(:video, submission)
  create_submission(pre_selection_application, stage_5)

  # Applicant at closed stage.
  closed_application = create_application(closed_applicant, application_round: round_in_pre_selection, application_stage: stage_7, agreements_verified: true)
  create_payment(closed_application)
  submission = create_submission(closed_application, stage_3)
  score_submission(:coding, submission)
  closed_application.batch_applicants << closed_co_applicant
  submission = create_submission(closed_application, stage_4)
  score_submission(:video, submission)
  create_submission(closed_application, stage_5)
end
