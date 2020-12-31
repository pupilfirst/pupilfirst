require 'rails_helper'

describe Applicants::CreateStudentService do
  subject { described_class.new(applicant) }

  let(:course) { create :course }
  let(:school) { course.school }
  let!(:level_one) { create :level, course: course }
  let(:applicant) { create :applicant, course: course }
  let(:tag) { Faker::Lorem.word }

  describe '#create' do
    it 'create a student account for the applicant' do
      student = subject.create(tag)
      user = student.user

      # The user should have same name and email
      expect(user.name).to eq(applicant.name)
      expect(user.email).to eq(applicant.email)

      # It should set the title for new users to 'Student'.
      expect(user.title).to eq('Student')

      # The user should be in the same school
      expect(user.school).to eq(school)

      # Applicant should have startup in level 1 of the course
      startup = Startup.where(name: applicant.name).first
      expect(startup.name).to eq(applicant.name)
      expect(startup.founders.count).to eq(1)
      expect(startup.level).to eq(level_one)

      # Founder should have tag "Public Signup"
      expect(startup.tag_list).to eq([tag])

      # Applicant should be destroyed
      expect(Applicant.where(email: applicant.email).count).to eq(0)
    end

    context 'when the user already exists' do
      let(:existing_coach) { create :faculty }
      let(:existing_title) { Faker::Job.title }
      let(:applicant) { create :applicant, course: course, email: existing_coach.user.email }

      before do
        existing_coach.user.update(title: existing_title)
      end

      it 'does not change the title of existing users' do
        student = subject.create(tag)

        expect(student.user.reload.title).to eq(existing_title)
      end
    end
  end
end
