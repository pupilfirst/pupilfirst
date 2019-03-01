require 'rails_helper'

describe ResourcePolicy do
  subject { described_class }

  let!(:school) { create :school }
  let!(:school_2) { create :school }

  let!(:course_s1_1) { create :course, school: school }
  let!(:course_s1_2) { create :course, school: school }
  let!(:course_s2) { create :course, school: school }

  let(:level_1_c1) { create :level, :one, course: course_s1_1 }
  let(:level_1_c2) { create :level, :one, course: course_s1_2 }
  let(:level_1_s2) { create :level, :one, course: course_s2 }

  let(:target_group_c1) { create :target_group, level: level_1_c1 }
  let(:target_group_c2) { create :target_group, level: level_1_c2 }
  let(:target_group_s2) { create :target_group, level: level_1_s2 }

  let(:target_1_c1) { create :target, target_group: target_group_c1 }
  let(:target_2_c1) { create :target, target_group: target_group_c1 }
  let(:target_c2) { create :target, target_group: target_group_c2 }
  let(:target_s2) { create :target, target_group: target_group_s2 }

  let(:startup) { create :startup, level: level_1_c1 }
  let(:founder) { startup.founders.first }

  let(:user) do
    OpenStruct.new(
      current_user: startup.founders.first.user,
      current_founder: startup.founders.first,
      current_school: school
    )
  end

  let!(:public_resource_s1) { create :resource, school: school, public: true }
  let!(:public_resource_c2) { create :resource, school: school, public: true, targets: [target_c2] }
  let!(:resource_s1) { create :resource, school: school, public: false }
  let!(:resource_1_c1) { create :resource, school: school, public: false, targets: [target_1_c1] }
  let!(:resource_2_c1) { create :resource, school: school, public: false, targets: [target_2_c1] }
  let!(:resource_c2) { create :resource, school: school, public: false, targets: [target_c2] }
  let!(:public_resource_s2) { create :resource, school: school_2, public: true }
  let!(:resource_1_s2) { create :resource, school: school_2, public: false, targets: [target_s2] }

  before do
    # Create another founder in startup.
    create :founder, startup: startup
  end

  permissions :show? do
    context 'when founder is a member of course 1' do
      it 'does not allow access to unlinked private resources in school' do
        expect(subject).not_to permit(user, resource_s1)
      end

      it 'allows access to public resources in the school, regardless of course' do
        expect(subject).to permit(user, public_resource_s1)
        expect(subject).to permit(user, public_resource_c2)
      end

      it 'allows access to all private resources in the course he is a member of' do
        expect(subject).to permit(user, resource_1_c1)
        expect(subject).to permit(user, resource_2_c1)
      end

      it 'does not allow access to private resource in other courses of same school' do
        expect(subject).not_to permit(user, resource_c2)
      end

      it 'does not allow access to any resource belonging to a different school' do
        expect(subject).to_not permit(user, public_resource_s2)
        expect(subject).to_not permit(user, resource_1_s2)
      end
    end
  end
end
