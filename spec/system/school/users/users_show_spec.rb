require "rails_helper"

feature "Users Show", js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:school) { create :school, :current }
  let(:school_admin) { create :school_admin, school: school }
  let(:school_2) { create :school }
  let(:school_2_user) { create :user, school: school_2 }

  let(:organisation) { create :organisation, school: school }

  let(:user) do
    create :user,
           school: school,
           discord_user_id: Faker::Number.number(digits: 10).to_s,
           organisation: organisation
  end
  let(:user_affiliated) { create :user, affiliation: Faker::Company.name }

  let(:course_1) { create :course, school: school }
  let(:course_2) { create :course, school: school }

  let(:cohort_1) { create :cohort, course: course_1 }
  let(:cohort_2) { create :cohort, course: course_2 }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  before do
    create :faculty, user: user
    create :course_author, user: user, course: course_1
    create :student, user: user, cohort: cohort_1
    create :student, user: user, cohort: cohort_2
    FacultyCohortEnrollment.create!(
      cohort_id: cohort_1.id,
      faculty_id: Faculty.first.id
    )
    4.times { create :discord_role, school: school }

    cohort_1.update!(discord_role_ids: [DiscordRole.first.discord_id])
  end

  scenario "admin try to access user of another school" do
    sign_in_user school_admin.user, referrer: school_user_path(school_2_user)

    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "user with affiliation filled" do
    sign_in_user school_admin.user, referrer: school_user_path(user_affiliated)

    expect(page).not_to have_text(organisation.name)
    expect(page).to have_text(user_affiliated.affiliation)
  end

  scenario "admin access user of same school" do
    sign_in_user school_admin.user, referrer: school_user_path(user)

    expect(page).to have_text(user.name)
    expect(page).to have_text("Student • Coach • Author")
    expect(page).to have_text("##{user.id}")
    expect(page).to have_text(user.email)
    expect(page).to have_text(DiscordRole.first.name)
    expect(page).to have_text("##{user.discord_user_id}")
    expect(page).to have_text(organisation.name)

    courses = Course.order(name: :asc)

    course_taken_cards = all('[data-test-class="users-courses_taken"]')
    expect(course_taken_cards.size).to eq(2)
    course_taken_cards.each_with_index do |course_card, index|
      within course_card do
        expect(page).to have_text(courses[index].name)
        expect(page).to have_text(courses[index].cohorts.first.name)
      end
    end

    course_coached_cards = all('[data-test-class="users-courses_coached"]')
    expect(course_coached_cards.size).to eq(1)
    course_coached_cards.each do |course_card|
      within course_card do
        expect(page).to have_text(course_1.name)
      end
    end

    course_authored_cards = all('[data-test-class="users-courses_authored"]')
    expect(course_authored_cards.size).to eq(1)
    course_authored_cards.each do |course_card|
      within course_card do
        expect(page).to have_text(course_1.name)
      end
    end
  end
end
