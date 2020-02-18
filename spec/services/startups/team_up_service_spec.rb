require 'rails_helper'

describe Startups::TeamUpService do
  subject { described_class }

  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two }
  let(:startup_1) { create :startup, level: level_1 }
  let(:startup_2) { create :startup, level: level_1 }
  let(:startup_3) { create :startup, level: level_2 }
  let(:faculty_1) { create :faculty, school: startup_1.school }
  let(:faculty_2) { create :faculty, school: startup_1.school }

  let(:founder_1) { startup_1.founders.first }
  let(:founder_2) { startup_1.founders.second }
  let(:founder_3) { startup_2.founders.first }
  let(:founder_4) { startup_2.founders.second }
  let(:founder_5) { startup_3.founders.second }

  let!(:founders_in_same_level) { Founder.where(id: [founder_1.id, founder_2.id, founder_3.id, founder_4.id]) }
  let!(:founders_in_different_levels) { Founder.where(id: [founder_5.id, founder_2.id]) }
  let(:team_name) { Faker::Lorem.words(number: 2).join(' ') }

  before do
    FacultyStartupEnrollment.create!(faculty: faculty_1, startup: startup_1, safe_to_create: true)
    FacultyStartupEnrollment.create!(faculty: faculty_2, startup: startup_2, safe_to_create: true)
  end

  describe '#team_up' do
    it 'forms a new team with specified founders and updates faculty enrollments' do
      expect { subject.new(founders_in_same_level).team_up(team_name) }.to(change { Startup.count }.from(3).to(2))

      last_startup = Startup.last

      # New startup has expected properties.
      expect(last_startup.founders.pluck(:id)).to match_array(founders_in_same_level.pluck(:id))
      expect(last_startup.name).to eq(team_name)

      expect(founder_1.reload.startup.founders.count).to eq(4)
      expect(founder_1.startup.faculty.pluck(:id)).to match_array([faculty_1.id, faculty_2.id])
    end

    it 'raises an exception when founders belong to different levels' do
      expect { subject.new(founders_in_different_levels).team_up(team_name) }.to raise_error(RuntimeError, 'Students must belong to the same level for teaming up')
    end
  end
end
