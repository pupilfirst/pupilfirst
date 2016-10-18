require 'rails_helper'

describe TeamLeadRestorationService, focus: true do
  let!(:batch_application_with_team_lead) { create :batch_application, :paid }
  let!(:batch_application_without_team_lead_1) { create :batch_application, :paid }
  let!(:batch_application_without_team_lead_2) { create :batch_application, :paid }

  let(:details_for_team_lead_1) do
    name = Faker::Name.name
    { 'success' => true, 'payment_request' => { 'email' => Faker::Internet.email(name), 'buyer_name' => name } }
  end

  let(:details_for_team_lead_2) do
    name = Faker::Name.name
    { 'success' => true, 'payment_request' => { 'email' => Faker::Internet.email(name), 'buyer_name' => name } }
  end

  before do
    # Delete two team_leads (skip validation)
    delete_ids = [batch_application_without_team_lead_1.team_lead.id, batch_application_without_team_lead_2.team_lead.id]
    BatchApplicant.where(id: delete_ids).delete_all

    # Mock Instamojo
    allow_any_instance_of(Instamojo).to receive(:raw_payment_request_details).and_return(details_for_team_lead_1, details_for_team_lead_2)
  end

  context 'dry run' do
    it 'makes no changes' do
      expect { subject.execute }.to_not change(BatchApplicant, :count)
    end
  end

  context 'not dry run' do
    subject { TeamLeadRestorationService.new(dry_run: false) }

    it 'restores two team leads' do
      expect { subject.execute }.to change(BatchApplicant, :count).from(1).to(3)

      team_lead_1 = batch_application_without_team_lead_1.team_lead
      team_lead_2 = batch_application_without_team_lead_2.team_lead

      expect(batch_application_without_team_lead_1.batch_applicants.first).to eq(team_lead_1)
      expect(batch_application_without_team_lead_2.batch_applicants.first).to eq(team_lead_2)
      expect(batch_application_without_team_lead_1.payment.batch_applicant).to eq(team_lead_1)
      expect(batch_application_without_team_lead_2.payment.batch_applicant).to eq(team_lead_2)
    end
  end
end
