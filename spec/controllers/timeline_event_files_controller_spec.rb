require "rails_helper"

RSpec.describe TimelineEventFilesController, type: :controller do
  let(:course) { create :course }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let!(:student) { create :student, course: course }
  let!(:target) { create :target, target_group: target_group }
  let!(:timeline_event) { create :timeline_event, :with_owners, owners: [student], target: target }
  let!(:timeline_event_file) { create :timeline_event_file, timeline_event: timeline_event }

  describe "#download" do
    context "when assignment has discussion enabled" do
      context "when user is peer student" do
        let(:peer_student) { create :student, course: course }
        let!(:assignment) { create :assignment, target: timeline_event.target, discussion: true }

      it "should redirect to the file" do
        sign_in peer_student.user

        get :download, params: { id: timeline_event_file.id }

        expect(response).to redirect_to(
          /\/rails\/active_storage\/blobs\/redirect\/.*\/#{timeline_event_file.file.filename}\z/
        )
        end
      end
    end
  end
end
