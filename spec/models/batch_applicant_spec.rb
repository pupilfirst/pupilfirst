require 'rails_helper'

RSpec.describe BatchApplicant, type: :model do
  subject { create :batch_applicant }

  context 'when batch applicant is a team_lead' do
    let!(:batch_application) { create :batch_application, team_lead: subject }

    it 'blocks destruction' do
      expect do
        subject.destroy
      end.to_not change(batch_application.batch_applicants, :count)

      expect(subject.errors).to_not be_empty
    end
  end
end
