require 'rails_helper'

describe Courses::AddStudentsService do
  subject { described_class.new(course, notify: notify) }

  let!(:course) { create :course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:student_1_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email) }
  let!(:student_2_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, title: Faker::Lorem.words(number: 2).join(' '), tags: ['Tag 1', 'Tag 2']) }
  let!(:student_3_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, team_name: 'new_team', tags: ["Tag 3"]) }
  let!(:student_4_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, team_name: 'new_team', tags: ["Tag 4"]) }
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
      expect(course.school.founder_tag_list).to match_array(['Tag 1', 'Tag 2', 'Tag 3', 'Tag 4'])

      # Email notifications
      open_email(student_1_data.email)

      email_subject = current_email.subject

      expect(email_subject).to eq("You have been added as a student in #{course.school.name}")

      # Check if students are teamed up correctly
      new_team = Startup.find_by(name: 'new_team')

      expect(new_team.founders.map { |f| f.email }).to match_array([student_3_data.email, student_4_data.email])
      expect(new_team.tag_list).to match_array(["Tag 3", "Tag 4"])
    end

    it 'returns the IDs of newly added students' do
      students_data = [student_1_data, student_2_data, student_3_data, student_4_data]

      response = subject.add(students_data)

      student_ids = Founder.joins(:user).
        where(users: { email: [student_1_data.email, student_2_data.email, student_3_data.email, student_4_data.email] }).
        pluck(:id)

      expect(response.length).to eq(4)
      expect(response).to contain_exactly(*student_ids)
    end

    it 'publishes student_added event for each student' do
      students_data = [student_1_data, student_2_data, student_3_data, student_4_data]

      notification_service = instance_double('Developers::NotificationService')
      allow(notification_service).to receive(:execute)
      subject =
        described_class.new(
          course,
          notify: notify,
          notification_service: notification_service
        )
      subject.add(students_data)
      students = User.where(email: students_data.map(&:email))
      students.each do |student|
        expect(notification_service).to have_received(:execute).with(
          course,
          :student_added,
          student,
          course
        )
      end
    end

    context 'course already has students' do
      let!(:persisted_team_1) { create :startup, level: level_1 }
      let!(:persisted_team_2) { create :startup, level: level_1 }
      let!(:student_1) { persisted_team_1.founders.first }
      let!(:student_2) { persisted_team_2.founders.first }
      let!(:data_with_existing_student_email) { OpenStruct.new(name: Faker::Name.name, email: student_1.email) }
      let!(:data_with_existing_student_email_different_casing) { OpenStruct.new(name: Faker::Name.name, email: student_2.email.capitalize) }

      it 'ignores persisted student emails when present in the list to add' do
        students_data = [student_1_data, student_2_data, data_with_existing_student_email, data_with_existing_student_email_different_casing]

        expect { subject.add(students_data) }.to change { course.founders.count }.by(2)
        expect(student_1.reload.startup).to eq(persisted_team_1)
        expect(student_2.reload.startup).to eq(persisted_team_2)
      end
    end

    context 'when a student being added is already a registered user' do
      let(:name) { Faker::Name.name }
      let(:title) { Faker::Job.title }
      let(:affiliation) { Faker::Company.name }
      let!(:user) { create :user, name: name, email: 'user@example.com', title: title, affiliation: affiliation }

      it 'onboards the student without altering their name, title or affiliation' do
        students_data = [OpenStruct.new(name: Faker::Name.name, email: 'User@example.com')]

        expect { subject.add(students_data) }.to change { course.founders.count }.by(1)
        expect(user.reload.name).to eq(name)
        expect(user.title).to eq(title)
        expect(user.affiliation).to eq(affiliation)
      end
    end

    context 'when the data includes a student alone in a team' do
      let!(:student_data) { OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email, team_name: 'Alone in this team') }

      it 'onboards the student as a "standard" student' do
        expect { subject.add([student_data]) }.to change { course.founders.count }.by(1)

        student_user = User.find_by(email: student_data.email)
        expect(student_user.founders.first.startup.name).to eq(student_user.name)
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
