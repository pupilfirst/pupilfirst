require "rails_helper"

feature "Course calendar feature for students and coaches", js: true do
  include UserSpecHelper

  # Setup a course with different cohorts, with a student enrolled in one cohort and a coach assigned to both cohorts
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:course_2) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:cohort_2) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let!(:student) { create :student, cohort: cohort }
  let!(:coach) { create :faculty, school: school }

  before { coach.cohorts << [cohort, cohort_2] }

  context "when the course has no calendars" do
    scenario "student sees no calendar" do
      sign_in_user student.user, referrer: calendar_course_path(course)

      expect(page).to have_text("No event scheduled")
    end
  end

  context "when the course has calendars and events" do
    let!(:course_calendar) { create :calendar, course: course }
    let!(:cohort_calendar) { create :calendar, course: course }
    let!(:calendar_cohort_2) { create :calendar, course: course }
    let!(:calendar_course_2) { create :calendar, course: course_2 }

    before { cohort_calendar.cohorts << cohort }
    before { calendar_cohort_2.cohorts << cohort_2 }

    # create some events for course calendar
    let!(:event_1) do
      create :calendar_event,
             :with_link,
             calendar: course_calendar,
             start_time: Time.current.beginning_of_month + 10.days
    end

    # Create some events for cohorts calendar
    let!(:event_2) do
      create :calendar_event,
             :with_link,
             calendar: cohort_calendar,
             start_time: event_1.start_time
    end

    let!(:event_3) do
      create :calendar_event,
             :with_link,
             calendar: cohort_calendar,
             start_time: Time.current.beginning_of_month + 12.days
    end

    let!(:event_next_month) do
      create :calendar_event,
             :with_link,
             calendar: cohort_calendar,
             start_time: event_1.start_time + 1.month
    end

    # Create event for a calendar that is assigned to a cohort student is not part of
    let!(:event_4) do
      create :calendar_event,
             :with_link,
             calendar: calendar_cohort_2,
             start_time: event_1.start_time
    end

    # Create some events for another course
    let!(:event_5) do
      create :calendar_event,
             calendar: calendar_course_2,
             start_time: event_3.start_time
    end

    scenario "student visits calendar page for enrolled course" do
      sign_in_user student.user, referrer: calendar_course_path(course)

      expect(page).to have_text("Events")

      # Check that the events are displayed in the calendar
      visit(
        calendar_course_path(
          course,
          date: event_1.start_time.strftime("%Y-%m-%d")
        )
      )

      expect(page).to have_text(event_1.title)
      expect(page).to have_text(event_1.calendar.name)
      expect(page).to have_text(event_2.title)
      expect(page).to have_text(event_2.description)

      # Check upcoming events
      within("div#upcoming-events") do
        expect(page).to have_text(
          "Upcoming events in #{event_1.start_time.strftime("%B")}"
        )
        expect(page).to have_text(event_3.title)
        expect(page).to have_link(event_3.link_title, href: event_3.link_url)
      end

      # Check that events from other cohorts or courses are not displayed and events from next month are not displayed
      expect(page).not_to have_text(event_next_month.title)
      expect(page).not_to have_text(event_4.title)
      expect(page).not_to have_text(event_5.title)
    end

    scenario "coach visits calendar page" do
      sign_in_user coach.user, referrer: calendar_course_path(course)

      expect(page).to have_text("Events")

      # Check that the events are displayed in the calendar
      visit(
        calendar_course_path(
          course,
          date: event_1.start_time.strftime("%Y-%m-%d")
        )
      )

      expect(page).to have_text(event_1.title)
      expect(page).to have_text(event_1.calendar.name)
      expect(page).to have_text(event_2.title)

      # Check upcoming events
      within("div#upcoming-events") do
        expect(page).to have_text(
          "Upcoming events in #{event_1.start_time.strftime("%B")}"
        )
        expect(page).to have_text(event_3.title)
      end

      # Coach gets to see events from all cohorts he is part of
      expect(page).to have_text(event_4.title)

      # Check that events from other cohorts or courses are not displayed and events from next month are not displayed
      expect(page).not_to have_text(event_next_month.title)
      expect(page).not_to have_text(event_5.title)
    end

    scenario "student visits calendar page for a course he is not enrolled" do
      sign_in_user student.user, referrer: calendar_course_path(course_2)

      expect(page).to have_text("The page you were looking for doesn't exist")
    end

    context "when a coach in the school has a student profile" do
      let(:coach) { create :faculty, school: school, user: student.user }

      # Remove the coach from the cohorts of the course
      before { coach.cohorts = [] }

      scenario "coach visits calendar page of the course he is a student" do
        sign_in_user coach.user, referrer: calendar_course_path(course)

        expect(page).to have_text("Events")

        # Check that the events are displayed in the calendar
        visit(
          calendar_course_path(
            course,
            date: event_1.start_time.strftime("%Y-%m-%d")
          )
        )

        expect(page).to have_text(event_1.title)
        expect(page).to have_text(event_2.title)
      end
    end
  end
end
