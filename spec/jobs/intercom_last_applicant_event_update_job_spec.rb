require 'rails_helper'

describe IntercomLastApplicantEventUpdateJob do
  subject { described_class }

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.team_lead }
  let(:intercom_client) { instance_double IntercomClient }
  let(:intercom_user) { double 'Intercom User' }

  before do
    allow(IntercomClient).to receive(:new).and_return(intercom_client)
  end

  it 'finds and updates user' do
    expect(intercom_client).to receive(:find_or_create_user).with(
      email: founder.email,
      name: founder.name
    ).and_return(intercom_user)

    expect(intercom_client).to receive(:add_tag_to_user).with(intercom_user, 'Applicant')
    expect(intercom_client).to receive(:add_note_to_user).with(intercom_user, 'Auto-tagged as <em>Applicant</em>')
    expect(intercom_client).to receive(:update_user).with(intercom_user, last_applicant_event: 'Submitted Application')

    subject.perform_now(founder, 'submitted_application')
  end
end
