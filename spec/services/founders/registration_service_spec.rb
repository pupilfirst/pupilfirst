require 'rails_helper'

describe Founders::RegistrationService do
  subject { described_class }

  describe '#register' do
    let(:founder_params) do
      {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        phone: '9876543210',
        reference: Faker::Lorem.word,
        college_text: Faker::Lorem.word
      }
    end

    let(:mailer) { double UserSessionMailer }

    let(:name_generator) { OpenStruct.new(fun_name: Faker::Name.name) }

    # Ensure a level zero exists for successfully creating a blank startup
    let!(:level_zero) { Level.create!(name: Faker::Name.name, number: 0) }

    before do
      allow(Startups::ProductNameGeneratorService).to receive(:new).and_return(name_generator)
    end

    context 'when the founder is not an existing SV.CO user' do
      it 'creates a founder with given params, a blank startup for the founder, a user and an intercom applicant' do
        expect(UserSessionMailer).to receive(:send_login_token).with(kind_of(User), nil, true).and_return(mailer)
        expect(mailer).to receive(:deliver_later)
        expect(IntercomNewApplicantCreateJob).to receive(:perform_later).with(kind_of(Founder))

        expect(Founder.count).to eq(0)
        expect(User.count).to eq(0)

        subject.new(founder_params).register

        expect(Founder.count).to eq(1)
        expect(User.count).to eq(1)

        new_founder = Founder.last

        expect(new_founder.name).to eq(founder_params[:name])
        expect(new_founder.email).to eq(founder_params[:email])
        expect(new_founder.phone).to eq(founder_params[:phone])
        expect(new_founder.reference).to eq(founder_params[:reference])
        expect(new_founder.college_text).to eq(founder_params[:college_text])
        expect(new_founder.startup.product_name).to eq(name_generator.fun_name)

        new_startup = new_founder.startup

        expect(new_startup.product_name).to_not be_blank
        expect(new_startup.level).to eq(level_zero)
      end
    end

    context 'when the founder is an existing SV.CO user' do
      let!(:user) { User.create!(email: founder_params[:email]) }
      it 'creates a founder with given params and updates user without creating a new user' do
        expect { subject.new(founder_params).register }.to change { User.count }.by(0)
      end
    end
  end
end
