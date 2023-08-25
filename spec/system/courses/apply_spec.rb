require "rails_helper"

feature "Apply for public courses", js: true do
  include UserSpecHelper
  include HtmlSanitizerSpecHelper

  # The basics.
  let(:school) { create :school, :current }
  let(:school_2) { create :school }
  let(:public_course) { create :course, school: school, public_signup: true }
  let(:cohort) { create :cohort, course: public_course }
  let!(:level_one) { create :level, course: public_course }
  let(:private_course) { create :course, school: school }
  let(:public_course_in_school_2) do
    create :course, school: school_2, public_signup: true
  end
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email(name: name) }
  let(:name_2) { Faker::Name.name }
  let(:email_2) { Faker::Internet.email(name: name_2) }
  let(:student) { create :student, cohort: cohort }
  let(:token) { Faker::Crypto.md5 }
  let(:saved_tag) { Faker::Lorem.word }
  let(:bounced_email) { Faker::Internet.email }
  let!(:bounce_report) { create :bounce_report, email: bounced_email }

  before do
    public_course.update!(default_cohort: cohort)
    school.student_tag_list.add(saved_tag)
    school.save!
  end

  scenario "public sign up for a public course" do
    visit apply_course_path(
            public_course,
            name: name,
            email: email,
            tag: saved_tag
          )

    # The fields should already be filled in.
    expect(page).to have_content(public_course.name)
    expect(page).to have_selector("input[value='#{name}']")
    expect(page).to have_selector("input[value='#{email}']")

    click_button "Apply"

    expect(page).to have_content("We've sent you a verification mail")

    applicant = Applicant.where(email: email).first

    expect(applicant.name).to eq(name)
    expect(applicant.email).to eq(email)
    expect(applicant.login_mail_sent_at).not_to eq(nil)

    open_email(email)

    body = sanitize_html(current_email.body)

    expect(body).to include(public_course.name)
    expect(body).to match(/[a-zA-Z0-9\-_]{22}/)
    expect(current_email.subject).to eq("Verify Your Email Address")

    expect(body).to include(
      "To activate your #{public_course.school.name} account"
    )

    applicant.regenerate_login_token
    visit enroll_applicants_path(applicant.original_login_token)

    expect(page).to have_content("Welcome to #{school.name}!")
    expect(page).to have_content(applicant.name)
    expect(page).to have_content(public_course.name)

    student = User.with_email(applicant.email).first.students.first

    expect(student.tag_list).to include(saved_tag)
    expect(student.tag_list).not_to include("Public Signup")
  end

  context "When course has a processing url" do
    let(:processing_url) do
      "https://www.example.com/q?course_id=${course_id}&applicant_id=${applicant_id}&name=${name}&email=${email}"
    end
    let(:applicant) { create :applicant, course: public_course }

    before { public_course.update!(processing_url: processing_url) }

    scenario "applicant tries to sign up multiple times in quick succession" do
      visit apply_course_path(public_course, name: name, email: email)

      click_button "Apply"

      expect(page).to have_content("We've sent you a verification mail")

      applicant = Applicant.where(email: email).first

      open_email(email)

      expect(current_email.subject).to eq(
        "Complete your #{public_course.name} course application"
      )

      expect(sanitize_html(current_email.body)).to include(
        "We've received your application to the #{public_course.name} course at #{public_course.school.name}"
      )

      expected_url =
        "https://www.example.com/q?course_id=#{public_course.id}&applicant_id=#{applicant.id}&name=#{applicant.name}&email=#{applicant.email}"

      applicant.regenerate_login_token

      visit enroll_applicants_path(applicant.original_login_token)

      # User should be redirected to the processing_url.
      expect(page).to have_current_path(expected_url, url: true)
    end
  end

  scenario "applicant tries to sign up multiple times in quick succession" do
    visit apply_course_path(public_course)

    expect(page).to have_content(public_course.name)

    fill_in "Email", with: email_2
    fill_in "Name", with: name_2
    click_button "Apply"

    expect(page).to have_content("We've sent you a verification mail")

    visit apply_course_path(public_course)

    expect(page).to have_content(public_course.name)

    fill_in "Email", with: email_2
    fill_in "Name", with: name_2
    click_button "Apply"

    expect(page).to have_content(
      "An email was sent less than two minutes ago. Please wait for a few minutes before trying again"
    )
  end

  scenario "applicant signing up without a tag is given a default tag" do
    visit apply_course_path(public_course, name: name, email: email)
    click_button "Apply"

    expect(page).to have_content("We've sent you a verification mail")

    applicant = Applicant.last
    applicant.regenerate_login_token
    visit enroll_applicants_path(applicant.original_login_token)

    expect(page).to have_content("Welcome to #{school.name}!")
    expect(Student.last.tag_list).to include("Public Signup")
  end

  scenario "applicant signing up with an unknown tag is given the default tag" do
    visit apply_course_path(
            public_course,
            name: name,
            email: email,
            tag: "An unknown tag"
          )
    click_button "Apply"

    expect(page).to have_content("We've sent you a verification mail")

    applicant = Applicant.last
    applicant.regenerate_login_token
    visit enroll_applicants_path(applicant.original_login_token)

    expect(page).to have_content("Welcome to #{school.name}!")

    student = Student.last

    expect(student.tag_list).to include("Public Signup")
    expect(student.tag_list).not_to include("An unknown tag")
  end

  scenario "applicant tag is remembered even if user navigates away before returning and applying" do
    visit apply_course_path(public_course, tag: saved_tag)

    expect(page).to have_content(public_course.name)

    visit course_path(public_course)

    expect(page).to have_content(public_course.description)

    visit apply_course_path(public_course, name: name, email: email)
    click_button "Apply"

    expect(page).to have_content("We've sent you a verification mail")

    applicant = Applicant.last
    applicant.regenerate_login_token
    visit enroll_applicants_path(applicant.original_login_token)

    expect(Student.last.tag_list).to include(saved_tag)
  end

  scenario "user visits a public course in other school" do
    visit apply_course_path(public_course_in_school_2)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(public_course_in_school_2.name)
  end

  scenario "a student in the course tries public enrollment" do
    user = student.user

    visit apply_course_path(public_course)
    fill_in "Email", with: user.email
    fill_in "Name", with: user.name
    click_button "Apply"

    expect(page).to have_text(
      "You are already enrolled in #{public_course.name} course"
    )
  end

  scenario "a student in the course tries public enrollment with a different email casing" do
    user = student.user

    visit apply_course_path(public_course)
    fill_in "Email", with: user.email.upcase
    fill_in "Name", with: user.name
    click_button "Apply"

    expect(page).to have_text(
      "You are already enrolled in #{public_course.name} course"
    )
  end

  scenario "user tries to access a private course page" do
    visit apply_course_path(private_course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(private_course.name)
  end

  scenario "user tries to access enrollment page without a valid token" do
    visit enroll_applicants_path(token)

    expect(page).to have_text("Sign in")
    expect(page).to have_text("That one-time link has expired, or is invalid")
  end

  scenario "applicant with bounced email attempts enrollment in a public course" do
    visit apply_course_path(public_course)

    expect(page).to have_content(public_course.name)

    fill_in "Email", with: bounced_email
    fill_in "Name", with: name_2
    click_button "Apply"

    expect(page).to have_text(
      "The email address you supplied cannot be used because an email we sent earlier bounced"
    )
  end

  context "when school has privacy policy" do
    before do
      create :school_string, :privacy_policy, school: school
      create :school_string, :terms_and_conditions, school: school_2
    end

    scenario "applicant can only see link to the privacy policy" do
      visit apply_course_path(public_course)

      expect(page).to have_link(
        "Privacy Policy",
        href: "/agreements/privacy-policy"
      )
      expect(page).not_to have_link(
        "Terms & Conditions",
        href: "/agreements/terms-and-conditions"
      )
    end
  end

  context "when school has terms and conditions" do
    before do
      create :school_string, :privacy_policy, school: school_2
      create :school_string, :terms_and_conditions, school: school
    end

    scenario "applicant can only see link to the terms and conditions" do
      visit apply_course_path(public_course)

      expect(page).not_to have_link(
        "Privacy Policy",
        href: "/agreements/privacy-policy"
      )
      expect(page).to have_link(
        "Terms & Conditions",
        href: "/agreements/terms-and-conditions"
      )
    end
  end

  context "when school has both agreements" do
    before do
      create :school_string, :privacy_policy, school: school
      create :school_string, :terms_and_conditions, school: school
    end

    scenario "applicant can see links to both agreements" do
      visit apply_course_path(public_course)

      expect(page).to have_link(
        "Privacy Policy",
        href: "/agreements/privacy-policy"
      )
      expect(page).to have_link(
        "Terms & Conditions",
        href: "/agreements/terms-and-conditions"
      )
    end
  end
end
