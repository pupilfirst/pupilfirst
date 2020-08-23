require 'rails_helper'

describe TimelineEvents::CreateWebhookDataService do
  subject { described_class.new(submission) }
  let(:course) { create :course }
  let(:level) { create :level, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:criterion) { create :evaluation_criterion, course: course }
  let!(:target) { create :target, target_group: target_group, evaluation_criteria: [criterion] }
  let(:submission) { create :timeline_event, target: target }

  describe '#data' do
    it 'will return data on a predefined format' do
      expected_response = {
        id: submission.id,
        created_at: submission.created_at,
        updated_at: submission.updated_at,
        target_id: submission.target_id,
        checklist: submission.checklist,
        target: {
          id: target.id,
          title: target.title,
          evaluation_criteria: [
            {
              name: criterion.name,
              max_grade: criterion.max_grade,
              pass_grade: criterion.pass_grade,
              grade_labels: criterion.grade_labels
            }
          ]
        }
      }

      data = subject.data
      expect(data).to eq(expected_response)
    end
  end
end
