require "rails_helper"

describe TimelineEvents::CreateWebhookDataService do
  subject { described_class.new(submission) }

  let(:course) { create :course }
  let(:level) { create :level, course: course }
  let(:target_group) { create :target_group, level: level }
  let(:criterion) { create :evaluation_criterion, course: course }

  let(:target) do
    create :target,
           :with_shared_assignment,
           target_group: target_group,
           given_evaluation_criteria: [criterion]
  end

  let(:submission) { create :timeline_event, target: target }
  let(:student) { create :student }

  let!(:pdf_file) { create :timeline_event_file, timeline_event: submission }

  let!(:png_file) do
    create :timeline_event_file,
           file_path: "files/icon_pupilfirst.png",
           timeline_event: submission
  end

  describe "#data" do
    before { submission.timeline_event_owners.create!(student: student) }
    it "returns data appropriate for sending via webhook" do
      expected_target_data = {
        id: target.id,
        title: target.title,
        evaluation_criteria: [
          {
            id: criterion.id,
            name: criterion.name,
            max_grade: criterion.max_grade,
            grade_labels: criterion.grade_labels
          }
        ]
      }

      pdf_file_data =
        hash_including(
          filename: "pdf-sample.pdf",
          content_type: "application/pdf",
          byte_size: 7945,
          checksum: "+n1+ZQss7GjzArMbooI12A==",
          url:
            %r{https://test\.host/rails/active_storage/blobs/.*/pdf-sample\.pdf}
        )

      image_file_data =
        hash_including(
          filename: "icon_pupilfirst.png",
          content_type: "image/png",
          byte_size: 10_026,
          checksum: "m5ZqQ7BpvaojhnIlEkoRiQ==",
          url:
            %r{https://test\.host/rails/active_storage/blobs/.*/icon_pupilfirst\.png}
        )

      data = subject.data

      expect(data[:id]).to eq(submission.id)
      expect(data[:created_at]).to eq(submission.created_at)
      expect(data[:updated_at]).to eq(submission.updated_at)
      expect(data[:target_id]).to eq(submission.target_id)
      expect(data[:checklist]).to eq(submission.checklist)
      expect(data[:level_number]).to eq(level.number)
      expect(data[:students]).to eq(submission.students.pluck(:id))
      expect(data[:target]).to eq(expected_target_data)
      expect(data[:files]).to include(pdf_file_data)
      expect(data[:files]).to include(image_file_data)
    end

    context "when the submission has been graded" do
      let(:submission) { create :timeline_event, :evaluated, target: target }

      let!(:submission_grading) do
        create :timeline_event_grade,
               evaluation_criterion: criterion,
               timeline_event: submission
      end

      it "includes grades in the response" do
        data = subject.data

        expect(data[:grades]).to eq(
          { criterion.id => submission_grading.grade }
        )

        expect(data[:evaluator]).to eq(submission.evaluator.name)
        expect(data[:evaluated_at]).to eq(submission.evaluated_at)
      end
    end

    context "when the submission does not have evaluation criteria (auto-accepted)" do
      let(:target) do
        create :target,
               :with_shared_assignment,
               target_group: target_group,
               given_evaluation_criteria: []
      end

      let(:submission) { create :timeline_event, :passed, target: target }

      it "leaves out evaluation criteria from the data" do
        expect(subject.data[:target][:evaluation_criteria]).to be_empty
      end
    end
  end
end
