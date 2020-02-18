require 'rails_helper'

describe Users::InitializeSchoolService do
  subject { described_class.new(user, course) }

  let(:school) { create :school }
  let(:new_school) { create :school }

  let!(:user) { create :user, school: new_school }
  let(:course) { create :course, school: school }

  let(:level_one) { create :level, :one, course: course }
  let(:target_group_l1_1) { create :target_group, level: level_one, milestone: true }
  let!(:target_l1_1_1) { create :target, :with_content, :for_team, target_group: target_group_l1_1 }

  let(:new_name) { Faker::Lorem.words(number: 2).join(' ') }

  describe '#execute' do
    it 'create initializes a school with a new course, coach, student and community' do
      # user should not have a student or coach profile
      expect(user.founders).to eq([])
      expect(user.faculty).to eq(nil)
      expect(new_school.courses.count).to eq(0)

      subject.execute

      # should create a student profile
      expect(user.reload.founders.count).to eq(1)
      # should create a coach profile
      expect(user.faculty.present?).to be(true)
      # should clone the course to new school
      expect(new_school.courses.count).to eq(1)
      expect(new_school.courses.first.slice(:name, :description)).to match_array(course.slice(:name, :description))
      # coach should be assigned to the new course
      expect(user.faculty.courses.first).to eq(new_school.courses.first)
      # new school should have a community
      expect(new_school.communities.count).to eq(1)
      # community should be linked to the new course
      expect(new_school.communities.first.courses).to eq(new_school.courses)
    end
  end
end
