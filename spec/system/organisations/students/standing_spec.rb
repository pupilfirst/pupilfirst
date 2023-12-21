require "rails_helper"

feature "User standing", js: true do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:organisation) { create :organisation, school: school }
  let!(:organisation_2) { create :organisation, school: school }
  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin, organisation: organisation, user: org_admin_user
  end

  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }

  let(:student_user) do
    create :user, school: school, organisation: organisation
  end

  let(:student) { create :student, user: student_user, cohort: cohort }

  let!(:student_from_another_org) do
    user = create :user, school: school, organisation: organisation_2

    create :student, user: user, cohort: cohort
  end

  let!(:standing_1) { create :standing, school: school, default: true }
  let!(:standing_2) { create :standing, school: school }
  let!(:standing_3) { create :standing, school: school }

  around { |example| Time.use_zone(org_admin_user.time_zone) { example.run } }

  scenario "org admin cannot see student standings if school standing is disabled" do
    sign_in_user org_admin_user, referrer: standing_org_student_path(student)

    expect(page).to have_text(student.user.name)

    expect(page).to have_text(student.user.full_title)

    expect(page).to have_text("Standing is not enabled for this school")
  end

  context "when school standing is enabled" do
    before { school.update!(configuration: { enable_standing: true }) }

    scenario "org admin visits student standing page with no standing logs" do
      sign_in_user org_admin_user, referrer: standing_org_student_path(student)

      expect(page).to have_current_path(standing_org_student_path(student))

      expect(page).to have_text(student.user.name)

      expect(page).to have_text(student.user.full_title)

      expect(page).to have_text(standing_1.name)

      expect(page).to have_text("There are no entries in the log")

      expect(page).not_to have_link("View Code of Conduct")
    end

    context "org student user has standing logs created" do
      let!(:standing_log_1) do
        create :user_standing,
               user: student.user,
               standing: standing_1,
               creator: school_admin.user
      end
      let!(:standing_log_2) do
        create :user_standing,
               user: student.user,
               standing: standing_2,
               creator: school_admin.user
      end
      let!(:standing_log_3) do
        create :user_standing,
               user: student.user,
               standing: standing_3,
               creator: school_admin.user
      end

      scenario "org admin visits standing page" do
        sign_in_user org_admin_user,
                     referrer: standing_org_student_path(student)

        expect(page).to have_current_path(standing_org_student_path(student))

        expect(page).to have_text(student.user.name)

        expect(page).to have_text(student.user.full_title)

        within("div[aria-label='Current standing card']") do
          expect(page).to have_text(standing_3.name)
        end

        within("div[aria-label='Current standing shield']") do
          svg_content = find("svg")
          expect(svg_content[:fill]).to include(standing_3.color)
        end

        expect(page).to have_text(standing_1.name)
        expect(page).to have_text(
          standing_log_1.created_at.strftime("%B %-d, %Y")
        )
        expect(page).to have_text(
          standing_log_1.created_at.strftime("%-l:%M %p")
        )
        expect(page).to have_text(standing_log_1.reason)

        expect(page).to have_text(standing_2.name)
        expect(page).to have_text(
          standing_log_2.created_at.strftime("%B %-d, %Y")
        )
        expect(page).to have_text(
          standing_log_2.created_at.strftime("%-l:%M %p")
        )
        expect(page).to have_text(standing_log_2.reason)

        expect(page).to have_text(standing_3.name)
        expect(page).to have_text(
          standing_log_3.created_at.strftime("%B %-d, %Y")
        )
        expect(page).to have_text(
          standing_log_3.created_at.strftime("%-l:%M %p")
        )
        expect(page).to have_text(standing_log_3.reason)

        expect(page).not_to have_link("View Code of Conduct")
      end
    end
  end

  scenario "org admin can not access standing page of a student from another org" do
    sign_in_user org_admin_user,
                 referrer: standing_org_student_path(student_from_another_org)

    expect(page).to have_text("The page you were looking for doesn't exist")
  end
end
