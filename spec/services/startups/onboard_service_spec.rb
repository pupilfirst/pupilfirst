require 'rails_helper'

describe Startups::OnboardService do
  let(:closed_round) { create :application_round, :closed_stage }
  let(:batch_application) { create :batch_application, :closed_stage, application_round: closed_round }
  let!(:batch_application_expired) { create :batch_application, :pre_selection_stage, application_round: closed_round }

  before do
    create :tet_joined
  end

  subject { described_class.new(batch_application.batch) }

  describe '#invite' do
    it 'creates startups' do
      expect { subject.execute }.to change(Startup, :count).by(1)
    end

    it 'creates founders' do
      expect { subject.execute }.to change(Founder, :count).by(batch_application.batch_applicants.count)
    end

    it 'sets up startups correctly' do
      subject.execute

      new_startup = batch_application.reload.startup

      expect(new_startup.product_name).to match(/[A-Z][a-z]+\s[A-Z][a-z]+/)
      expect(new_startup.batch).to eq(batch_application.batch)
    end

    it 'sets up founders correctly' do
      subject.execute

      startup_admin = batch_application.reload.team_lead.founder

      expect(startup_admin.startup_admin?).to eq(true)

      co_applicant = batch_application.cofounders.first
      cofounder = co_applicant.founder

      expect(cofounder.user).to eq(User.find_by(email: co_applicant.email))
      expect(cofounder.name).to eq(co_applicant.name)
      expect(cofounder.email).to eq(co_applicant.email)
      expect(cofounder.gender).to eq(co_applicant.gender)
      expect(cofounder.born_on).to eq(co_applicant.born_on)
      expect(cofounder.college_id).to eq(co_applicant.college_id)
      expect(cofounder.roles).to eq([co_applicant.role])
      expect(cofounder.phone).to eq(co_applicant.phone)
      expect(cofounder.communication_address).to eq(co_applicant.current_address)
      expect(cofounder.identification_proof).to_not be_blank
    end

    it 'sends emails to founders' do
      pending 'Disabled because of https://trello.com/c/nyszoy5p'

      subject.execute

      open_email(batch_application.reload.team_lead.founder.email)

      expect(current_email.subject).to match(/Your startup journey awaits/)
    end

    it 'has one verified timeline event' do
      subject.execute

      expect(batch_application.reload.startup.timeline_events.verified.count).to eq(1)
    end

    context 'when product name collision occurs' do
      let!(:third_batch_application) { create :batch_application, :closed_stage, application_round: closed_round }
      let(:mock_service) { instance_double('Startups::ProductNameGeneratorService') }

      before do
        allow(Startups::ProductNameGeneratorService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:fun_name).and_return('foo', 'foo', 'bar')
      end

      it 'creates startup with another name' do
        subject.execute

        product_names = Startup.pluck(:product_name)
        expect(product_names.count).to eq(2)
        expect(product_names - %w(foo bar)).to be_empty
      end
    end
  end
end
