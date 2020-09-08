require 'rails_helper'

describe TimelineEvents::CreateWebhookDataService do
  subject { described_class.new(submission) }
  let(:course) { create :course }
  let(:level) { create :level, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:criterion) { create :evaluation_criterion, course: course }
  let!(:target) { create :target, target_group: target_group, evaluation_criteria: [criterion] }
  let(:submission) { create :timeline_event, target: target }
  let!(:pdf_file) { create :timeline_event_file, timeline_event: submission }
  let!(:png_file) { create :timeline_event_file, file_path: 'files/icon_pupilfirst.png', timeline_event: submission }

  describe '#data' do
    it 'returns data appropriate for sending via webhook' do
      expected_target_data = {
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

      pdf_file_data = hash_including(
        filename: 'pdf-sample.pdf',
        content_type: 'application/pdf',
        byte_size: 7945,
        checksum: '+n1+ZQss7GjzArMbooI12A==',
        url: %r{https://test\.host/rails/active_storage/blobs/.*/pdf-sample\.pdf}
      )

      image_file_data = hash_including(
        filename: 'icon_pupilfirst.png',
        content_type: 'image/png',
        byte_size: 10026,
        checksum: 'm5ZqQ7BpvaojhnIlEkoRiQ==',
        url: %r{https://test\.host/rails/active_storage/blobs/.*/icon_pupilfirst\.png}
      )

      data = subject.data

      expect(data[:id]).to eq(submission.id)
      expect(data[:created_at]).to eq(submission.created_at)
      expect(data[:updated_at]).to eq(submission.updated_at)
      expect(data[:target_id]).to eq(submission.target_id)
      expect(data[:checklist]).to eq(submission.checklist)
      expect(data[:target]).to eq(expected_target_data)
      expect(data[:files]).to include(pdf_file_data)
      expect(data[:files]).to include(image_file_data)
    end
  end
end
