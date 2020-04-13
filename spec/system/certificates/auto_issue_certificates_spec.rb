require 'rails_helper'

feature "Automatic issuance of certificates", js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let!(:certificate) { create :certificate, :active, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }

  # Create few teams
  let!(:team) { create :team, level: level_1 }

  # Shortcut to a student we'll refer to frequently.
  let!(:student_1) { create :student, startup: team }
  let!(:student_2) { create :student, startup: team }

  let(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let(:target_group_l2) { create :target_group, level: level_2, milestone: true }

  let!(:target_l1) { create :target, :with_markdown, :team, target_group: target_group_l1 }
  let!(:target_l2) { create :target, :with_markdown, :team, target_group: target_group_l2 }

  def complete_first_target
    sign_in_user student_1.user, referer: target_path(target_l2)

    click_button 'Mark As Complete'

    expect(page).to have_text('Target has been marked as complete')

    # No certificate should be issued at this point.
    expect(student_1.user.issued_certificates.count).to eq(0)

    dismiss_notification
    click_button 'Close'
    click_link target_l2_2.title
  end

  context 'when the student is not in the final level' do
    scenario 'student completes the last milestone target' do
      sign_in_user student_1.user, referer: target_path(target_l1)

      click_button 'Mark As Complete'

      expect(page).to have_text('Target has been marked as complete')

      # No certificate should be issued.
      expect(IssuedCertificate.count).to eq(0)
    end
  end

  context 'when the student is in the final level' do
    let!(:team) { create :team, level: level_2 }

    scenario 'student receives certificate upon completion of sole milestone target' do
      sign_in_user student_1.user, referer: target_path(target_l2)

      click_button 'Mark As Complete'

      expect(page).to have_text('Target has been marked as complete')

      expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(student_1.user.id, student_2.user.id)

      # Check the details of the first certificate.
      issued_certificate = student_1.user.issued_certificates.first

      expect(issued_certificate.certificate).to eq(certificate)
      expect(issued_certificate.name).to eq(student_1.name)
      expect(issued_certificate.serial_number).to match(/^\d{6}-[A-Z0-9]{6}$/)
    end

    context 'when there are multiple milestone targets' do
      let(:target_group_l2_2) { create :target_group, level: level_2, milestone: true }

      context 'when the second target is simply marked as complete' do
        let!(:target_l2_2) { create :target, :with_markdown, :team, target_group: target_group_l2, title: 'foo' }

        scenario 'student completed second and final milestone target' do
          complete_first_target

          click_button 'Mark As Complete'

          expect(page).to have_text('Target has been marked as complete')

          # Both students should have a certificate at this point.
          expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(student_1.user.id, student_2.user.id)
        end
      end

      context 'when the second target is completed by a visiting a link' do
        let!(:target_l2_2) { create :target, :with_markdown, :team, target_group: target_group_l2, link_to_complete: 'https://www.example.com' }

        scenario 'student completed second and final milestone target' do
          complete_first_target

          click_button 'Visit Link To Complete'

          expect(page).to have_text('Target has been marked as complete')

          # Both students should have a certificate at this point.
          expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(student_1.user.id, student_2.user.id)
        end
      end

      context 'when the second target is completed with a quiz' do
        let(:target_l2_2) { create :target, :with_markdown, :team, target_group: target_group_l2 }
        let!(:quiz) { create :quiz, :with_question_and_answers, target: target_l2_2 }

        scenario 'student completed second and final milestone target' do
          complete_first_target

          find('.course-overlay__body-tab-item', text: 'Take Quiz').click
          find('.quiz-root__answer', text: quiz.quiz_questions.first.answer_options.first.value).click
          click_button('Submit Quiz')

          expect(page).to have_content('Your responses have been saved')

          # Both students should have a certificate at this point.
          expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(student_1.user.id, student_2.user.id)
        end
      end

      context 'when the second target also requires submission and review' do
        let(:evaluation_criterion) { create :evaluation_criterion, course: course }
        let!(:target_l2_2) { create :target, :with_markdown, :with_default_checklist, :team, target_group: target_group_l2, evaluation_criteria: [evaluation_criterion] }
        let(:coach) { create :faculty, user: student_1.user }

        before do
          create :faculty_course_enrollment, faculty: coach, course: course
        end

        scenario 'student completed second and final milestone target' do
          complete_first_target

          find('.course-overlay__body-tab-item', text: 'Complete').click
          replace_markdown Faker::Lorem.sentence
          click_button 'Submit'

          expect(page).to have_content('Your submission has been queued for review')

          # No issued certificates, yet.
          expect(IssuedCertificate.count).to eq(0)

          # Switch to the review interface and set a fail grade for it.
          visit timeline_event_path(target_l2_2.timeline_events.last)
          find("div[title='Bad']").click
          click_button 'Save grades'

          expect(page).to have_text('The submission has been marked as reviewed')

          # No issued certificates, still.
          expect(IssuedCertificate.count).to eq(0)

          # Undo the grading and set a pass grade.
          click_button('Undo Grading')
          find("div[title='Good']").click
          click_button 'Save grades'

          # Both students should now have a now certificate.
          expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(student_1.user.id, student_2.user.id)
        end
      end
    end

    context 'when the milestone target is completed individually' do
      let!(:target_l2) { create :target, :with_markdown, :student, target_group: target_group_l2 }

      scenario 'each student completes the last target', broken: true do
        sign_in_user student_1.user, referer: target_path(target_l2)

        click_button 'Mark As Complete'

        expect(page).to have_text('Target has been marked as complete')

        # No certificate should be issued, yet.
        expect(IssuedCertificate.count).to eq(0)

        sign_in_user student_2.user, referer: target_path(target_l2)

        click_button 'Mark As Complete'

        expect(page).to have_text('Target has been marked as complete')

        # Both students get certificate when the last student in team completes the target.
        expect(IssuedCertificate.pluck(:user_id)).to contain_exactly(student_1.user.id, student_2.user.id)
      end
    end

    context 'when there is no active certificate' do
      let!(:certificate) { create :certificate, course: course }

      scenario 'students never receive certificates upon completion' do
        pending 'An active certificate is necessary for the automatic issuance of certificates.'
        expect(1).to eq(2)
      end
    end

    context 'when there are no milestone targets' do
      let(:target_group_l2) { create :target_group, level: level_2 }

      scenario 'students never receive certificates' do
        pending 'At least one milestone is required in the final level for the issuance of certificates.'
        expect(1).to eq(2)
      end
    end

    context 'when a certificate has already been issued do' do
      scenario 'student resubmits the final target' do
        pending "It doesn't issue a duplicate certificate."
        expect(1).to eq(2)
      end
    end
  end
end
