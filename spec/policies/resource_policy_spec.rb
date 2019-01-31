require 'rails_helper'

describe ResourcePolicy do
  subject { described_class }

  let!(:school) { create :school }
  let!(:course_1) { create :course, school: school }
  let!(:course_2) { create :course, school: school }
  let!(:course_3) { create :course }

  let(:level_0) { create :level, :zero, course: course_1 }
  let(:level_1) { create :level, :one, course: course_1 }
  let(:level_2) { create :level, :two, course: course_1 }
  let(:level_1_s1) { create :level, :two, course: course_2 }

  let(:startup) { create :startup, level: level_1 }
  let(:founder) { startup.founders.first }

  let(:user) do
    OpenStruct.new(
      current_user: startup.founders.first.user,
      current_founder: startup.founders.first,
      current_school: school
    )
  end

  let!(:public_resource) { create :resource, course: course_1, public: true }
  let!(:resource_1_c1) { create :resource, course: course_1, public: false }
  let!(:resource_2_c1) { create :resource, course: course_1, public: false }
  let!(:resource_3_c1) { create :resource, course: course_1, public: false }
  let!(:resource_1_c2) { create :resource, course: course_2, public: false }
  let!(:resource_1_c3) { create :resource, course: course_3, public: true }
  let!(:resource_2_c3) { create :resource, course: course_3, public: false }

  permissions :show? do
    context 'when founder is a member of course 1' do
      it 'allows access to public resources in the school' do
        expect(subject).to permit(user, public_resource)
      end

      it 'allows access to all private resources in the course he is a member of' do
        expect(subject).to permit(user, resource_1_c1)
        expect(subject).to permit(user, resource_2_c1)
        expect(subject).to permit(user, resource_3_c1)
      end

      it 'does not allow access to private resources in another course he is not part of from same school' do
        expect(subject).to_not permit(user, resource_1_c2)
      end

      it 'does not allow access to any resource belonging to a different school' do
        expect(subject).to_not permit(user, resource_1_c3)
        expect(subject).to_not permit(user, resource_2_c3)
      end
    end
  end
end
