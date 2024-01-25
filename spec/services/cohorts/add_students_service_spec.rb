require "rails_helper"

describe Cohorts::AddStudentsService do
  subject { described_class.new(cohort, notify: notify) }

  let!(:course) { create :course }
  let!(:cohort) { create :cohort, course: course }
  let!(:level_1) { create :level, :one, course: course }
  let!(:student_1_data) do
    OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email)
  end
  let!(:student_2_data) do
    OpenStruct.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      title: Faker::Lorem.words(number: 2).join(" "),
      tags: ["Tag 1", "Tag 2"]
    )
  end
  let!(:student_3_data) do
    OpenStruct.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      team_name: "new_team",
      tags: ["Tag 3"]
    )
  end
  let!(:student_4_data) do
    OpenStruct.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      team_name: "new_team",
      tags: ["Tag 4"]
    )
  end
  let!(:notify) { true }

  describe "#add" do
    it "add given list of students to the cohort" do
      students_data = [
        student_1_data,
        student_2_data,
        student_3_data,
        student_4_data
      ]

      expect { subject.add(students_data) }.to change {
        cohort.students.count
      }.by(4)
      expect(cohort.teams.count).to eq(1)

      # Check attributes are saved correctly for students
      student_2_user = User.find_by(email: student_2_data.email)
      expect(student_2_user.name).to eq(student_2_data.name)
      expect(student_2_user.title).to eq(student_2_data.title)
      expect(student_2_user.students.first.tag_list).to match_array(
        ["Tag 1", "Tag 2"]
      )
      expect(cohort.school.student_tag_list).to match_array(
        ["Tag 1", "Tag 2", "Tag 3", "Tag 4"]
      )

      # Email notifications
      open_email(student_1_data.email)

      email_subject = current_email.subject

      expect(email_subject).to eq(
        "#{student_1_data.name}, you have been added as a student in #{cohort.school.name}"
      )

      # Check if students are teamed up correctly
      new_team = Team.find_by(name: "new_team")

      expect(new_team.students.map { |f| f.email }).to match_array(
        [student_3_data.email, student_4_data.email]
      )
    end

    it "returns the IDs of newly added students" do
      students_data = [
        student_1_data,
        student_2_data,
        student_3_data,
        student_4_data
      ]

      response = subject.add(students_data)

      student_ids =
        Student
          .joins(:user)
          .where(
            users: {
              email: [
                student_1_data.email,
                student_2_data.email,
                student_3_data.email,
                student_4_data.email
              ]
            }
          )
          .pluck(:id)

      expect(response.length).to eq(4)
      expect(response).to contain_exactly(*student_ids)
    end

    it "publishes student_added event for each student" do
      students_data = [
        student_1_data,
        student_2_data,
        student_3_data,
        student_4_data
      ]

      notification_service = instance_double("Developers::NotificationService")
      allow(notification_service).to receive(:execute)
      subject =
        described_class.new(
          cohort,
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
          cohort
        )
      end
    end

    context "course already has students" do
      let!(:persisted_team_1) { create :team_with_students, cohort: cohort }
      let!(:persisted_team_2) { create :team_with_students, cohort: cohort }
      let!(:student_1) { persisted_team_1.students.first }
      let!(:student_2) { persisted_team_2.students.first }
      let!(:data_with_existing_student_email) do
        OpenStruct.new(name: Faker::Name.name, email: student_1.email)
      end
      let!(:data_with_existing_student_email_different_casing) do
        OpenStruct.new(
          name: Faker::Name.name,
          email: student_2.email.capitalize
        )
      end

      it "ignores persisted student emails when present in the list to add" do
        students_data = [
          student_1_data,
          student_2_data,
          data_with_existing_student_email,
          data_with_existing_student_email_different_casing
        ]

        expect { subject.add(students_data) }.to change {
          cohort.students.count
        }.by(2)
        expect(student_1.reload.team).to eq(persisted_team_1)
        expect(student_2.reload.team).to eq(persisted_team_2)
      end
    end

    context "when a student being added is already a registered user" do
      let(:name) { Faker::Name.name }
      let(:title) { Faker::Job.title }
      let(:affiliation) { Faker::Company.name }
      let!(:user) do
        create :user,
               name: name,
               email: "user@example.com",
               title: title,
               affiliation: affiliation
      end

      it "onboards the student without altering their name, title or affiliation" do
        students_data = [
          OpenStruct.new(name: Faker::Name.name, email: "User@example.com")
        ]

        expect { subject.add(students_data) }.to change {
          cohort.students.count
        }.by(1)
        expect(user.reload.name).to eq(name)
        expect(user.title).to eq(title)
        expect(user.affiliation).to eq(affiliation)
      end
    end

    context "when the data includes a student alone in a team" do
      let!(:student_data) do
        OpenStruct.new(
          name: Faker::Name.name,
          email: Faker::Internet.email,
          team_name: "Alone in this team"
        )
      end

      it 'onboards the student as a "standard" student without a team' do
        expect { subject.add([student_data]) }.to change {
          cohort.students.count
        }.by(1)

        expect { subject.add([student_data]) }.to change {
          cohort.teams.count
        }.by(0)
      end
    end

    context "notifications is not enabled" do
      let(:notify) { false }

      it "does not send notifications to the new students added" do
        students_data = [student_1_data, student_2_data]

        expect { subject.add(students_data) }.to change {
          cohort.students.count
        }.by(2)

        open_email(student_1_data.email)

        expect(current_email).to eq(nil)
      end
    end

    context "when notify flag is set to false" do
      let(:notify) { false }

      it "does not regenerate login token" do
        students_data = [student_1_data, student_2_data]

        expect { subject.add(students_data) }.to change {
          cohort.students.count
        }.by(2)

        student_1_token_digest =
          User.find_by(email: student_1_data.email).login_token_digest

        expect(student_1_token_digest).to eq(nil)
      end
    end

    context "when notify flag is set to true" do
      let(:notify) { true }

      it "regenerates login token" do
        students_data = [student_1_data, student_2_data]

        expect { subject.add(students_data) }.to change {
          cohort.students.count
        }.by(2)

        student_1_token_digest =
          User.find_by(email: student_1_data.email).login_token_digest

        expect(student_1_token_digest).not_to eq(nil)
      end
    end
  end
end
