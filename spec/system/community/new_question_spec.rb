require 'rails_helper'

feature 'Question creator', js: true do
  include UserSpecHelper

  # Setup a course with students and target for community.
  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let!(:community) { create :community, school: school }
  let(:team) { create :team, level: level_1 }
  let(:student) { create :student, startup: team }
  let!(:question_1) { create :question, title: 'Foo bar', community: community, creator: student.user }
  let!(:question_2) { create :question, title: 'Foobar foobaz', community: community, creator: student.user }
  let!(:question_3) { create :question, title: 'Baz bar', community: community, creator: student.user }

  before do
    create :community_course_connection, course: course, community: community
  end

  scenario 'user is shown suggestions when creating a new question' do
    sign_in_user(student.user, referer: new_question_community_path(community))
    fill_in('Question', with: 'foo')

    expect(page).to have_link(question_1.title, href: "/questions/#{question_1.id}")
    expect(page).to have_link(question_2.title, href: "/questions/#{question_2.id}")
    expect(page).not_to have_text(question_3.title)

    fill_in('Question', with: ' ')

    expect(page).not_to have_text(question_1.title)
    expect(page).not_to have_text(question_2.title)

    fill_in('Question', with: 'BAZ')

    expect(page).to have_link(question_3.title, href: "/questions/#{question_3.id}")
    expect(page).not_to have_text(question_1.title)
    expect(page).not_to have_text(question_2.title)
  end
end
