require 'rails_helper'

feature 'Course authors editor', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a school with 2 school admins
  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }
  let(:course) { create :course, school: school }
  let!(:course_author) { create :course_author, course: course }
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email(name: name) }
  let(:name_for_edit) { Faker::Name.name }
  let(:user) { create :user }
  let(:name_for_user) { Faker::Name.name }
  let(:coach) { create :faculty, school: school }

  scenario 'school admin adds a new author to the course' do
    sign_in_user school_admin.user, referrer: authors_school_course_path(course)

    # Interface should show existing coaches
    expect(page).to have_text(course_author.user.name)

    # Add a new author
    click_button 'Add New Author'
    fill_in 'email', with: email
    fill_in 'name', with: name
    click_button 'Create Author'

    expect(page).to have_text("Author Created")

    dismiss_notification

    new_author_user = school.users.where(email: email).first

    expect(new_author_user.name).to eq(name)
    expect(new_author_user.title).to eq('Author')
    expect(CourseAuthor.exists?(user_id: new_author_user.id)).to eq(true)

    open_email(new_author_user.email)

    expect(current_email.subject).to include("You have been added as an author in #{course.name}")
    expect(current_email.body).to have_link("Sign in to Edit Course")

    # The new author should be immediately editable.
    click_link(new_author_user.name)

    expect(page).to have_button('Update Author', disabled: true)
  end

  scenario 'school admin edits an author' do
    sign_in_user school_admin.user, referrer: school_course_author_path(course, course_author)

    # Edit the author's name.
    fill_in 'name', with: name_for_edit
    click_button 'Update Author'

    expect(page).to have_text('Author Updated')

    dismiss_notification

    expect(course_author.user.reload.name).to eq(name_for_edit)
  end

  scenario 'school admin adds an existing user as an author', js: true do
    sign_in_user school_admin.user, referrer: authors_school_course_path(course)
    original_title = user.title

    click_button 'Add New Author'
    fill_in 'email', with: user.email
    fill_in 'name', with: name_for_user
    click_button 'Create Author'

    expect(page).to have_text("Author Created")

    dismiss_notification

    expect(school.users.where(email: user.email).count).to eq(1)
    expect(user.reload.name).to eq(name_for_user)
    expect(user.reload.title).to eq(original_title)
  end

  scenario 'school admin deletes an author' do
    sign_in_user school_admin.user, referrer: authors_school_course_path(course)

    accept_confirm do
      find("div[title='Delete #{course_author.user.name}'").click
    end

    expect(page).not_to have_text(course_author.user.name)
    expect(CourseAuthor.count).to eq(0)
  end

  scenario 'school admin attempts to add an admin as an author' do
    sign_in_user school_admin.user, referrer: new_school_course_author_path(course)

    fill_in 'email', with: school_admin.user.email
    fill_in 'name', with: name_for_user
    click_button 'Create Author'

    expect(page).to have_text('This user is already a school admin')
    expect(CourseAuthor.joins(:user).where(users: { email: school_admin.user.email })).to be_blank
  end

  scenario 'user who is not logged in tries to access course author editor interface' do
    visit authors_school_course_path(course)
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario 'logged in user who not a school admin to access course author editor interface' do
    sign_in_user coach.user, referrer: authors_school_course_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end
end
