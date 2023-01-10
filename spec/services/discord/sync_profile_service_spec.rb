require 'rails_helper'

describe Discord::SyncProfileService do
  subject { described_class }

  let(:discord_configuration) do
    {
      discord: {
        bot_token: 'bot_token',
        server_id: 'server_id',
        default_role_ids: ['default_role']
      }
    }
  end

  let(:school) { create :school, configuration: discord_configuration }
  let(:user) do
    create :user,
           school: school,
           discord_user_id: Faker::Number.number(digits: 18)
  end

  let(:cohort_1) do
    create :cohort,
           school: school,
           discord_role_ids: %w[role_1 role_2 role_shared]
  end

  let(:cohort_2) do
    create :cohort, school: school, discord_role_ids: %w[role_3 role_4]
  end

  let(:cohort_3) do
    create :cohort, school: school, discord_role_ids: %w[another_role]
  end

  let!(:student_1) { create :student, user: user, cohort: cohort_1 }
  let!(:student_2) { create :student, user: user, cohort: cohort_2 }
  let!(:student_3) { create :student, cohort: cohort_3 }

  describe '#execute' do
    context 'when a user has a discord user id' do
      it 'resets the roles' do
        expect(Discordrb::API::Server).to receive(:update_member).with(
          "Bot #{discord_configuration[:discord][:bot_token]}",
          discord_configuration[:discord][:server_id],
          user.discord_user_id,
          roles:
            a_collection_containing_exactly(
              'role_1',
              'role_2',
              'role_shared',
              'role_3',
              'role_4',
              'default_role'
            ),
          nick: user.name
        )

        subject.new(user).execute
      end
    end

    context 'when a user does not have a discord user id' do
      before { user.update(discord_user_id: nil) }
      it 'does not resets the roles' do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        subject.new(user).execute
      end
    end

    context 'when configuration is not present' do
      before { school.update!(configuration: {}) }
      it 'does not resets the roles' do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        subject.new(user).execute
      end
    end
  end
end
