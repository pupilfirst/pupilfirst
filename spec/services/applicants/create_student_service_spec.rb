require 'rails_helper'

describe Applicants::CreateStudentService do
  subject { described_class.new(applicant) }

  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let!(:level_one) { create :level, course: course }
  let(:applicant) { create :applicant, course: course }

  describe '#create' do
    it 'create a student account for the applicant' do
      student = subject.create
      user = student.user

      # The user should have same name and email
      expect(user.name).to eq(applicant.name)
      expect(user.email).to eq(applicant.email)

      # The user should be in the same school
      expect(user.school).to eq(school)

      # Applicant should have startup in level 1 of the course
      startup = Startup.where(name: applicant.name).first
      expect(startup.name).to eq(applicant.name)
      expect(startup.founders.count).to eq(1)
      expect(startup.level).to eq(level_one)

      # Founder should have tag "Public Signup"
      expect(student.tag_list).to eq(["Public Signup"])

      # Applicant should be destroyed
      expect(Applicant.where(email: applicant.email).count).to eq(0)
    end
  end
end
