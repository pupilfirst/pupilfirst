require "rails_helper"

feature "Courses Index", js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper
  include DevelopersNotificationsHelper

  # Setup a course with a single student target, ...
  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  def file_path(filename)
    File.absolute_path(
      Rails.root.join("spec", "support", "uploads", "files", filename)
    )
  end

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  context "when school has no course" do
    scenario "School admin sees create course option" do
      sign_in_user school_admin.user, referrer: school_courses_path

      expect(page).to have_text("Showing all 0 courses")
      expect(page).to have_button("Add New Course")
    end
  end

  context "when school has courses" do
    let!(:course_1) { create :course, :with_default_cohort, school: school }

    let!(:course_2) do
      create :course,
             :with_default_cohort,
             school: school,
             name: "Pupilfirst Demo Course"
    end

    let!(:course_ended) { create :course, :ended, school: school }

    let!(:course_archived) do
      create :course, school: school, archived_at: 1.day.ago
    end

    let(:course_name) { Faker::Lorem.words(number: 2).join " " }
    let(:description) { Faker::Lorem.sentences.join " " }

    scenario "School admin creates a course" do
      sign_in_user school_admin.user, referrer: school_courses_path

      # list all courses
      expect(page).to have_text("Add New Course")
      expect(page).to have_text(course_1.name)
      expect(page).to have_text(course_2.name)

      # Add a new course
      click_button "Add New Course"
      fill_in "Course name", with: course_name
      fill_in "Course description", with: description
      within("div#public-signup") { click_button "No" }
      click_button "Create Course"

      expect(page).to have_text("Course created successfully")

      dismiss_notification

      expect(page).to have_text(course_name)

      course = Course.last

      expect(course.name).to eq(course_name)
      expect(course.description).to eq(description)
      expect(course.about).to eq(nil)
      expect(course.enable_leaderboard).to eq(false)
      expect(course.public_signup).to eq(false)
      expect(course.public_preview).to eq(false)
      expect(course.progression_limit).to eq(1)
      expect(course.highlights).to eq([])
      expect(course.processing_url).to eq(nil)
    end

    context "when a course exists" do
      let(:new_course_name) { Faker::Lorem.words(number: 2).join " " }
      let!(:new_cohort) { create :cohort, course: course_1 }
      let(:new_about) { Faker::Lorem.paragraph }
      let(:new_description) { Faker::Lorem.sentences.join " " }
      let(:course_end_date) { Time.zone.today }
      let(:processing_url) { Faker::Internet.url }

      let(:highlights) do
        [
          {
            icon: Types::CourseHighlightInputType.allowed_icons.sample,
            title: Faker::Lorem.words(number: 2).join(" ").titleize,
            description: Faker::Lorem.paragraph
          },
          {
            icon: Types::CourseHighlightInputType.allowed_icons.sample,
            title: Faker::Lorem.words(number: 2).join(" ").titleize,
            description: Faker::Lorem.paragraph
          }
        ]
      end

      scenario "School admin edits an existing course" do
        sign_in_user school_admin.user,
                     referrer: "/school/courses/#{course_1.id}/details"

        fill_in "Course name",
                with: new_course_name,
                fill_options: {
                  clear: :backspace
                }

        fill_in "Course description",
                with: new_description,
                fill_options: {
                  clear: :backspace
                }

        replace_markdown new_about
        select "thrice", from: "progression-limit"
        within("div#public-signup") { click_button "Yes" }
        within("div#processing-url") { click_button "Yes" }
        fill_in "processing_url", with: processing_url
        click_button "Add Course Highlight"
        click_button "Add Course Highlight"

        within('div[data-highlight-index="2"]') do
          click_button "Select Icon"
          click_button "Select #{highlights.last[:icon]}"

          fill_in "highlight-2-title",
                  with: highlights.last[:title],
                  fill_options: {
                    clear: :backspace
                  }

          fill_in "highlight-2-description",
                  with: highlights.last[:description],
                  fill_options: {
                    clear: :backspace
                  }

          click_button "Move Down"
        end

        within('div[data-highlight-index="2"]') do
          click_button "Select Icon"

          click_button "Select #{highlights.first[:icon]}"

          fill_in "highlight-2-title",
                  with: highlights.first[:title],
                  fill_options: {
                    clear: :backspace
                  }

          fill_in "highlight-2-description",
                  with: highlights.first[:description],
                  fill_options: {
                    clear: :backspace
                  }
        end

        within('div[data-highlight-index="0"]') do
          click_button "Delete highlight"
          click_button "Delete highlight"
        end

        within("div#public-preview") { click_button "Yes" }

        click_button course_1.default_cohort.name
        click_button new_cohort.name

        click_button "Update Course"

        expect(page).to have_text("Course updated successfully")

        expect(course_1.reload.name).to eq(new_course_name)
        expect(course_1.description).to eq(new_description)
        expect(course_1.about).to eq(new_about)
        expect(course_1.public_signup).to eq(true)
        expect(course_1.public_preview).to eq(true)
        expect(course_1.progression_limit).to eq(3)
        expect(course_1.highlights).to eq(highlights.map(&:stringify_keys))
        expect(course_1.processing_url).to eq(processing_url)
        expect(course_1.default_cohort).to eq(new_cohort)
      end

      scenario "school admin changes the ordering of courses" do
        archived_index = course_archived.sort_index
        course_archived.update!(sort_index: course_2.sort_index)
        course_2.update!(sort_index: archived_index)

        sign_in_user school_admin.user, referrer: school_courses_path

        within("div[data-t='#{course_1.name}']") { click_button "Move Down" }
        sleep 0.5 # There's no UI reaction to the move, so we need to wait for the request to complete.

        expect(Course.order(:sort_index).pluck(:id).index(course_1.id)).to eq(3)

        expect(
          Course.order(:sort_index).pluck(:id).index(course_archived.id)
        ).to eq(1)

        within("div[data-t='#{course_1.name}']") { click_button "Move Up" }
        sleep 0.5

        expect(Course.order(:sort_index).pluck(:id).index(course_1.id)).to eq(0)

        expect(
          Course.order(:sort_index).pluck(:id).index(course_archived.id)
        ).to eq(1)
      end

      scenario "School admin sets other progression behaviors on existing course" do
        sign_in_user school_admin.user, referrer: school_courses_path

        find("button[title='Edit #{course_1.name}']").click

        click_button "Unlimited"
        click_button "Update Course"

        expect(page).to have_text("Course updated successfully")
        expect(course_1.reload.progression_limit).to eq(0)

        find("button[title='Edit #{course_1.name}']").click
        select "once", from: "progression-limit"

        click_button "Update Course"

        expect(page).to have_text("Course updated successfully")
        expect(course_1.reload.progression_limit).to eq(1)
      end

      scenario "School admin edits images associated with the course" do
        sign_in_user school_admin.user,
                     referrer: "/school/courses/#{course_1.id}/images"

        expect(page).to have_text("Please choose an image file.", count: 2)

        attach_file "course_thumbnail",
                    file_path("logo_lipsum_on_light_bg.png"),
                    visible: false

        attach_file "course_cover",
                    file_path("logo_lipsum_on_dark_bg.png"),
                    visible: false

        click_button "Update Images"

        expect(page).to have_text("Images have been updated successfully")

        find("button[title='Edit #{course_1.name}']").click
        click_button "Images"

        expect(page).to have_text(
          "Please pick a file to replace logo_lipsum_on_light_bg.png"
        )

        expect(page).to have_text(
          "Please pick a file to replace logo_lipsum_on_dark_bg.png"
        )

        expect(course_1.cover).to be_attached
        expect(course_1.thumbnail).to be_attached
      end

      scenario "School admin edits images associated with the archived course" do
        sign_in_user school_admin.user,
                     referrer: "/school/courses/#{course_archived.id}/images"

        expect(page).to have_text("Please choose an image file.", count: 2)

        attach_file "course_thumbnail",
                    file_path("logo_lipsum_on_light_bg.png"),
                    visible: false

        attach_file "course_cover",
                    file_path("logo_lipsum_on_dark_bg.png"),
                    visible: false

        click_button "Update Images"

        expect(page).to have_text("Images have been updated successfully")

        fill_in("Search", with: "archived")
        click_button "Pick Status: Archived"
        find("button[title='Edit #{course_archived.name}']").click
        click_button "Images"

        expect(page).to have_text(
          "Please pick a file to replace logo_lipsum_on_light_bg.png"
        )

        expect(page).to have_text(
          "Please pick a file to replace logo_lipsum_on_dark_bg.png"
        )

        expect(course_archived.cover).to be_attached
        expect(course_archived.thumbnail).to be_attached
      end
    end

    context "with many courses" do
      before { 23.times { create :course, :with_cohort, school: school } }

      scenario "school admin loads all courses" do
        sign_in_user school_admin.user, referrer: school_courses_path

        expect(page).to have_text("Showing 10 of 25 courses")

        click_button "Load More Courses..."

        expect(page).to have_text("Showing 20 of 25 courses")

        click_button "Load More Courses..."

        expect(page).to have_text("Showing all 25 courses")
        expect(page).not_to have_text("Load More Courses...")
      end

      scenario "school admin loads details route for last course" do
        sign_in_user school_admin.user,
                     referrer:
                       "/school/courses/#{school.courses.last.id}/details"

        expect(page).to have_text("EDIT COURSE DETAILS")
      end
    end

    scenario "user who is not logged in gets redirected to sign in page" do
      visit school_courses_path

      expect(page).to have_text("Please sign in to continue.")
    end

    scenario "school admin searches and filters courses" do
      sign_in_user school_admin.user, referrer: school_courses_path

      expect(page).to have_text("Status: Active")

      within("div[id='courses']") do
        expect(page).to have_text(course_1.name)
        expect(page).not_to have_text(course_ended.name)
        expect(page).not_to have_text(course_archived.name)
      end

      fill_in("Search", with: "ended")
      click_button "Pick Status: Ended"

      within("div[id='courses']") do
        expect(page).not_to have_text(course_1.name)
        expect(page).to have_text(course_ended.name)
        expect(page).not_to have_text(course_archived.name)
      end

      fill_in("Search", with: "archived")
      click_button "Pick Status: Archived"

      within("div[id='courses']") do
        expect(page).not_to have_text(course_1.name)
        expect(page).not_to have_text(course_ended.name)
        expect(page).to have_text(course_archived.name)
      end

      click_button "Remove selection: Archived"
      fill_in("Search", with: "pupilfirst demo course")
      click_button "Pick Search by name: pupilfirst demo course"

      within("div[id='courses']") { expect(page).to have_text(course_2.name) }
    end

    scenario "school admin filters archived courses" do
      sign_in_user school_admin.user, referrer: school_courses_path
      fill_in("Search", with: "archived")
      click_button "Pick Status: Archived"

      within("div[id='courses']") do
        expect(page).to have_text(course_archived.name)
        expect(page).not_to have_text("View public page")

        expect(page).not_to have_link(
          "View as Student",
          href: curriculum_course_path(course_1)
        )

        expect(page).not_to have_link(
          "Manage Students",
          href: school_course_students_path(course_1)
        )

        expect(page).not_to have_link(
          "View Calendar",
          href: calendar_events_school_course_path(course_1)
        )
      end
    end

    scenario "school admin has expected links and button on course card" do
      sign_in_user school_admin.user, referrer: school_courses_path

      within("div[data-t='#{course_1.name}']") do
        expect(page).to have_link(
          "View public page",
          href: course_path(course_1)
        )

        expect(page).to have_link(
          "View as Student",
          href: curriculum_course_path(course_1)
        )

        expect(page).to have_link(
          "Edit Curriculum",
          href: curriculum_school_course_path(course_1)
        )

        expect(page).to have_link(
          "Manage Students",
          href: school_course_students_path(course_1)
        )

        expect(page).to have_link(
          "View Calendar",
          href: calendar_events_school_course_path(course_1)
        )

        expect(page).to have_button("Edit Course Details")
      end
    end

    scenario "school admin visits details route for archived course" do
      sign_in_user school_admin.user,
                   referrer: "/school/courses/#{course_archived.id}/details"

      expect(page).to have_text("EDIT COURSE DETAILS")
    end

    context "when students exist in a course" do
      let!(:student) { create :student, cohort: course_1.cohorts.first }

      scenario "school admin archives a course" do
        notification_service = prepare_developers_notification

        sign_in_user school_admin.user,
                     referrer: "/school/courses/#{course_1.id}/actions"

        expect(page).to have_text("Do you want to archive the course?")

        accept_confirm { click_button("Archive Course") }

        expect(page).to have_text("Course archived successfully")
        expect(course_1.reload.archived_at).not_to eq(nil)
        expect(course_1.cohorts.first.ends_at).not_to eq(nil)

        within("div[id='courses']") do
          expect(page).not_to have_text(course_1.name)
        end

        expect_published(
          notification_service,
          course_1,
          :course_archived,
          school_admin.user,
          course_1
        )
      end
    end

    scenario "school admin un-archives a course" do
      notification_service = prepare_developers_notification
      sign_in_user school_admin.user, referrer: school_courses_path

      fill_in("Search", with: "archived")
      click_button "Pick Status: Archived"
      find("button[title='Edit #{course_archived.name}']").click
      click_button "Actions"

      expect(page).to have_text("Do you want to unarchive the course?")

      accept_confirm { click_button("Unarchive Course") }

      expect(page).to have_text("Course unarchived successfully")
      expect(course_archived.reload.archived_at).to eq(nil)

      within("div[id='courses']") do
        expect(page).not_to have_text(course_archived.name)
      end

      expect_published(
        notification_service,
        course_archived,
        :course_unarchived,
        school_admin.user,
        course_archived
      )
    end

    scenario "school admin makes a copy of a course" do
      sign_in_user school_admin.user, referrer: school_courses_path
      find("button[title='Edit #{course_1.name}']").click
      click_button "Actions"

      expect(page).to have_text("Do you want to create a copy of the course?")

      accept_confirm { click_button("Clone Course") }

      expect(page).to have_text(
        "Course copy requested. It will appear here soon!"
      )

      visit school_courses_path
      fill_in("Search", with: "ended")
      click_button "Pick Status: Ended"

      within("div[id='courses']") do
        expect(page).to have_text(course_1.name + " - copy")
      end
    end
  end
end
