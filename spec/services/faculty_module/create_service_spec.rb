require 'rails_helper'

describe FacultyModule::CreateService do
  subject { described_class.new(email, name, school) }
  let(:name) { (Faker::Lorem.words(2).join ' ').titleize }
  let(:email) { Faker::Internet.email }
  let(:school) { create :school }
  let(:course) { create :course, school: school }
  let(:faculty) { create :faculty, school: school }

  describe '#create' do
    context 'when a faculty profile does not exist in the current school' do
      it 'creates a new faculty profile' do
        faculty = subject.create

        expect(faculty.email).to eq(email)
      end
    end

    context 'when a faculty profile exist for the user in the current school' do
      let(:email) { faculty.email }

      it 'returns the existing faculty profile' do
        user = faculty.user

        expect { subject.create }.not_to(change { user.faculty.count })
      end
    end
  end
end
