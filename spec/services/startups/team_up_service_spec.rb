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

      last_team = Startup.last

      # New startup has expected properties.
      expect(last_team.founders.pluck(:id)).to match_array(founders_in_same_level.pluck(:id))
      expect(last_team.name).to eq(team_name)

      expect(founder_1.reload.startup.founders.count).to eq(4)
      expect(founder_1.startup.faculty.pluck(:id)).to match_array([faculty_1.id, faculty_2.id])
    end

    it 'raises an exception when founders belong to different levels' do
      expect { subject.new(founders_in_different_levels).team_up(team_name) }.to raise_error(RuntimeError, 'Students must belong to the same level for teaming up')
    end

    context 'when teams have some tags' do
      let(:startup_1) { create :startup, level: level_1, tag_list: %w[tag_a tag_b] }
      let(:startup_2) { create :startup, level: level_1, tag_list: %w[tag_c] }

      it 'copies the tags to a student who moves out' do
        expect { subject.new(Founder.where(id: founder_1.id)).team_up('foo') }.to(change { Startup.count }.from(3).to(4))

        new_team = founder_1.reload.startup

        expect(new_team.name).to eq('foo')
        expect(new_team.tag_list).to match_array(%w[tag_a tag_b])
      end

      it 'merges tags when two or more students join to form a team' do
        expect { subject.new(founders_in_same_level).team_up(team_name) }.to(change { Startup.count }.from(3).to(2))

        last_team = Startup.last

        expect(last_team.tag_list).to match_array(%w[tag_a tag_b tag_c])
      end
    end
  end
end
