require 'rails_helper'

describe TimelineEvents::CreateService do
  subject { described_class.new(params, student) }

  let(:student) { create :student }
  let(:level) { student.level }
  let(:target_group) { create :target_group, level: level }
  let(:target) { create :target, role: Target::ROLE_STUDENT, target_group: target_group }
  let(:links) { [Faker::Internet.url, Faker::Internet.url] }
  let(:description) { Faker::Lorem.sentence }
  let(:checklist) do
    [
      { 'title' => "File", 'result' => "", 'kind' => "files", 'status' => "noAnswer" },
      { 'title' => "Description", 'result' => description, 'kind' => "longText", 'status' => "noAnswer" }
    ]
  end

  let(:params) do
    {
      target: target,
      checklist: checklist
    }
  end

  describe '#execute' do
    it 'creates a new submission with the given params as the latest submission' do
      expect { subject.execute }.to change { TimelineEvent.count }.by(1)

      last_submission = TimelineEvent.last

      expect(last_submission.target).to eq(target)
      expect(last_submission.founders.pluck(:id)).to eq([student.id])
      expect(last_submission.checklist).to eq(checklist)
      expect(last_submission.latest).to eq(true)
    end

    context 'when target is a team target and student is in a team' do
      let(:student) { create :founder }
      let(:target) { create :target, role: Target::ROLE_TEAM, target_group: target_group }

      it 'creates submission linked to all students in team' do
        subject.execute

        last_submission = TimelineEvent.last

        expect(last_submission.founders.count).to eq(3)
        expect(last_submission.founders.pluck(:id)).to match_array(student.startup.founders.pluck(:id))
      end
    end

    context 'when previous submissions exist' do
      let(:another_team) { create :startup, level: level }
      let(:another_student) { another_team.founders.first }
      let!(:first_submission) { create :timeline_event, founders: [student], target: target }
      let!(:last_submission) { create :timeline_event, :latest, founders: [student], target: target }
      let!(:another_submission) { create :timeline_event, :latest, founders: [student, another_student], target: target }

      it 'removes the latest flag from previous latest submission of same set of students' do
        expect { subject.execute }.to change { TimelineEvent.count }.by(1)
        expect(TimelineEvent.last.latest).to eq(true)
        expect(last_submission.reload.latest).to eq(false)

        # Another submission that includes 'this' founder, plus another person, should be ignored.
        expect(another_submission.reload.latest).to eq(true)
      end
    end
  end
end
