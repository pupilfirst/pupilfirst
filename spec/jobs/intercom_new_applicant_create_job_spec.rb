require 'rails_helper'

describe IntercomNewApplicantCreateJob do
  subject { described_class }

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.team_lead }
  let(:intercom_client) { instance_double IntercomClient }
  let(:intercom_user) { double 'Intercom User' }

  before :all do
    IntercomNewApplicantCreateJob.mock = false
  end

  after :all do
    IntercomNewApplicantCreateJob.mock = true
  end

  before do
    allow(IntercomClient).to receive(:new).and_return(intercom_client)
  end

  it 'creates and updates user' do
    expect(intercom_client).to receive(:find_or_create_user).with(
      email: founder.email,
      name: founder.name
    ).and_return(intercom_user)

    expect(intercom_client).to receive(:update_user).with(
      intercom_user,
      phone: founder.phone,
      college: founder.college.name,
      university: founder.college.university.name,
      supplied_reference: founder.reference
    )

    expect(Intercom::LevelZeroStageUpdateJob).to receive(:perform_later).with(founder, Startup::ADMISSION_STAGE_SIGNED_UP)

    subject.perform_now(founder)
  end
end
