require "rails_helper"

feature "Calendars", js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:cohort_1) { create :cohort, course: course }
  let!(:cohort_2) { create :cohort, course: course }

  scenario "school admin creates calendars for course" do
    sign_in_user school_admin.user,
                 referrer: calendar_events_school_course_path(course)

    expect(page).to have_text("No calendars yet")

    # Create a new calendar.
    click_link "Add Calendar"
    expect(page).to have_text("Create new calendar")

    fill_in "calendar_name", with: "Master Calendar"
    click_button "Add calendar"

    dismiss_notification

    expect(course.calendars.count).to eq(1)
    new_calendar = course.calendars.first
    expect(new_calendar.name).to eq("Master Calendar")
    expect(new_calendar.cohorts.count).to eq(0)

    expect(page).to have_text("Master Calendar")

    expect(page).to have_link(
      "",
      href: edit_school_course_calendar_path(course, new_calendar)
    )

    ## Create a calendar linked to cohort
    click_link "Add Calendar"
    expect(page).to have_text("Create new calendar")

    fill_in "calendar_name", with: "Cohort 1 Calendar"

    # Select a cohort
    find("button[title='Select #{cohort_1.name}']").click
    click_button "Add calendar"

    dismiss_notification

    expect(course.calendars.count).to eq(2)
    new_calendar = course.calendars.last
    expect(new_calendar.name).to eq("Cohort 1 Calendar")
    expect(new_calendar.cohorts.count).to eq(1)
    expect(new_calendar.cohorts.first).to eq(cohort_1)

    expect(page).to have_text("Cohort 1 Calendar")
  end

  context "course has calendars" do
    # Create a calendar linked to cohort

    let!(:calendar_1) { create :calendar, course: course }
    let!(:calendar_3) { create :calendar, course: course, cohorts: [cohort_1] }

    scenario "school admin edits a calendar" do
      sign_in_user school_admin.user,
                   referrer: calendar_events_school_course_path(course)

      expect(page).to have_text(calendar_1.name)
      expect(page).to have_text(calendar_3.name)

      # Edit calendar 1
      click_link("", href: edit_school_course_calendar_path(course, calendar_1))

      expect(page).to have_text("Update calendar")

      fill_in "calendar[name]", with: "Some other name"

      # Add a cohort
      find("button[title='Select #{cohort_2.name}']").click
      click_button "Update calendar"

      dismiss_notification

      expect(page).to have_text("Some other name")

      expect(calendar_1.reload.name).to eq("Some other name")
      expect(calendar_1.cohorts.count).to eq(1)
      expect(calendar_1.cohorts.first).to eq(cohort_2)
    end

    scenario "school admin creates an event" do
      sign_in_user school_admin.user,
                   referrer: calendar_events_school_course_path(course)

      expect(page).to have_text(calendar_1.name)
      expect(page).to have_text(calendar_3.name)

      # Create an event
      click_link("Add an event")

      expect(page).to have_text("Add new event")

      fill_in "calendar_event[title]", with: "Some awesome event"
      select calendar_1.name, from: "calendar_event[calendar_id]"
      select "red", from: "calendar_event[color]"

      fill_in "calendar_event[start_time]", with: Time.now
      fill_in "calendar_event[link_title]", with: "Some link"
      fill_in "calendar_event[link_url]", with: "https://www.example.com"
      fill_in "calendar_event[description]", with: "Some description"

      click_button "Add event"

      dismiss_notification

      expect(page).to have_text("Some awesome event")
      new_event = CalendarEvent.last
      expect(new_event.title).to eq("Some awesome event")
      expect(new_event.calendar).to eq(calendar_1)
      expect(new_event.color).to eq("red")
      expect(new_event.link_title).to eq("Some link")
      expect(new_event.link_url).to eq("https://www.example.com")
      expect(new_event.description).to eq("Some description")

      ## Add another link to a different calendar

      click_link("Add an event")

      expect(page).to have_text("Add new event")

      fill_in "calendar_event[title]", with: "Some other event"
      select calendar_3.name, from: "calendar_event[calendar_id]"
      select "green", from: "calendar_event[color]"
      fill_in "calendar_event[start_time]", with: Time.now
      fill_in "calendar_event[link_title]", with: "Some other link"

      click_button "Add event"

      dismiss_notification

      expect(page).to have_text("Calendars")
      expect(page).to have_text("Some other event")
      expect(page).to have_text("Some awesome event")

      # Filter a calendar
      click_button "Select a calendar"

      within(".dropdown__list-2") { click_link(calendar_3.name) }

      expect(page).to_not have_text("Some awesome event")
      expect(page).to have_text("Some other event")
    end

    context("calendar has existing events") do
      let!(:calendar_event_1) do
        create :calendar_event, calendar: calendar_1, start_time: Time.now
      end
      let!(:calendar_event_2) do
        create :calendar_event, calendar: calendar_3, start_time: Time.now
      end

      scenario "school admin edits an event" do
        sign_in_user school_admin.user,
                     referrer: calendar_events_school_course_path(course)

        expect(page).to have_text(calendar_event_1.title)
        expect(page).to have_text(calendar_event_2.title)

        # Edit event 2
        click_link(
          href: school_course_calendar_event_path(course, calendar_event_2)
        )
        expect(page).to have_text(calendar_event_2.title)
        expect(page).to have_text(calendar_event_2.description)

        click_link("Edit")

        expect(page).to have_text("Edit #{calendar_event_2.title}")

        expect(page).to have_select(
          "calendar_event[calendar_id]",
          selected: calendar_3.name
        )
        fill_in "calendar_event[title]", with: "Some other title"
        fill_in "calendar_event[description]", with: "Some other description"
        select calendar_1.name, from: "calendar_event[calendar_id]"
        select "green", from: "calendar_event[color]"
        fill_in "calendar_event[link_title]", with: "Some other link"
        fill_in "calendar_event[link_url]", with: "https://www.example.com"

        click_button "Update event"

        dismiss_notification

        expect(page).to have_text("Some other title")
        expect(calendar_event_2.reload.title).to eq("Some other title")
        expect(calendar_event_2.description).to eq("Some other description")
        expect(calendar_event_2.calendar).to eq(calendar_1)
        expect(calendar_event_2.color).to eq("green")
        expect(calendar_event_2.link_title).to eq("Some other link")
        expect(calendar_event_2.link_url).to eq("https://www.example.com")
      end

      scenario "school admin deletes an event" do
        sign_in_user school_admin.user,
                     referrer: calendar_events_school_course_path(course)

        expect(page).to have_text(calendar_event_1.title)

        click_link(
          href: school_course_calendar_event_path(course, calendar_event_1)
        )
        expect(page).to have_text(calendar_event_1.title)

        # Delete event
        accept_confirm { click_button("Delete") }

        dismiss_notification

        expect(page).to_not have_text(calendar_event_1.title)

        expect(CalendarEvent.find_by(id: calendar_event_1.id)).to be_nil
      end
    end
  end
end
