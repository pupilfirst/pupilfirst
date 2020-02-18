require 'rails_helper'

describe FacultyModule::CreateService do
  subject { described_class }

  let(:name) { (Faker::Lorem.words(number: 2).join ' ').titleize }
  let(:email) { Faker::Internet.email }
  let(:title) { (Faker::Lorem.words(number: 2).join ' ').titleize }
  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let(:faculty) { create :faculty, school: school }

  describe '#create' do
    context 'when a faculty profile does not exist in the current school' do
      it 'creates a new faculty profile' do
        faculty_params = { name: name, email: email, school: school, title: title }

        expect { subject.new(faculty_params).create }.to change { Faculty.count }.by(1)

        faculty = school.faculty.last

        expect(faculty.email).to eq(email)
        expect(faculty.name).to eq(name)
        expect(faculty.title).to eq(title)
      end
    end

    context 'when a faculty profile exist for the user in the current school' do
      let(:email) { faculty.email }

      it 'returns the existing faculty profile' do
        faculty_params = { name: name, email: email, school: school, title: title }

        # The service should not create any new coaches.
        expect { subject.new(faculty_params).create }.not_to(change { Faculty.count })
      end
    end
  end
end
