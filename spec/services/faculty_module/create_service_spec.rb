require 'rails_helper'

describe FacultyModule::CreateService do
  subject { described_class }
  let(:name) { (Faker::Lorem.words(2).join ' ').titleize }
  let(:email) { Faker::Internet.email }
  let(:title) { (Faker::Lorem.words(2).join ' ').titleize }
  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let(:faculty) { create :faculty, school: school }

  describe '#create' do
    context 'when a faculty profile does not exist in the current school' do
      it 'creates a new faculty profile' do
        faculty_params = { name: name, email: email, school: school, title: title }
        faculty = subject.new(faculty_params).create

        expect(faculty.email).to eq(email)
      end
    end

    context 'when a faculty profile exist for the user in the current school' do
      let(:email) { faculty.email }

      it 'returns the existing faculty profile' do
        faculty_params = { name: name, email: email, school: school, title: title }
        user = faculty.user

        expect { subject.new(faculty_params).create }.not_to(change { user.faculty.count })
      end
    end
  end
end
