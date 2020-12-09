require 'rails_helper'

describe Courses::AddStudentsService do
  subject { described_class.new(course, notify: notify) }

  let!(:course) { create :course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:student_1_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email) }
  let!(:student_2_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, title: Faker::Lorem.words(number: 2).join(' '), tags: ['Tag 1', 'Tag 2']) }
  let!(:student_3_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, team_name: 'new_team') }
  let!(:student_4_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, team_name: 'new_team') }
  let!(:notify) { true }

  describe '#add' do
    it 'add given list of students to the course' do
      students_data = [student_1_data, student_2_data, student_3_data, student_4_data]

      expect { subject.add(students_data) }.to change { course.founders.count }.by(4)
      expect(course.startups.count).to eq(3)

      # Check attributes are saved correctly for students
      student_2_user = User.find_by(email: student_2_data.email)
      expect(student_2_user.name).to eq(student_2_data.name)
      expect(student_2_user.title).to eq(student_2_data.title)
      expect(student_2_user.founders.first.startup.tag_list).to match_array(['Tag 1', 'Tag 2'])
      expect(course.school.founder_tag_list).to match_array(['Tag 1', 'Tag 2'])

      # Email notifications
      open_email(student_1_data.email)

      email_subject = current_email.subject

      expect(email_subject).to eq("You have been added as a student in #{course.school.name}")

      # Check if students are teamed up correctly
      new_team = Startup.find_by(name: 'new_team')

      expect(new_team.founders.map { |f| f.email }).to match_array([student_3_data.email, student_4_data.email])
    end

    context 'course already has students' do
      let!(:persisted_team) { create :startup, level: level_1 }
      let!(:student) { persisted_team.founders.first }
      let!(:data_with_existing_student_email) { OpenStruct.new(name: Faker::Name.name, email: student.email) }

      it 'ignores persisted student emails when present in the list to add' do
        students_data = [student_1_data, student_2_data, data_with_existing_student_email]

        expect { subject.add(students_data) }.to change { course.founders.count }.by(2)
        expect(student.name).to_not eq(data_with_existing_student_email.name)
      end
    end

    context 'notifications is not enabled' do
      let(:notify) { false }

      it 'does not send notifications to the new students added' do
        students_data = [student_1_data, student_2_data]

        expect { subject.add(students_data) }.to change { course.founders.count }.by(2)

        open_email(student_1_data.email)

        expect(current_email).to eq(nil)
      end
    end
  end
end
