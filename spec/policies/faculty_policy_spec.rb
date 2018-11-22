require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  let(:level_0_startup) { create :level_0_startup }
  let(:level_1_startup) { create :startup, :subscription_active }
  let(:level_2_startup) { create :startup, :subscription_active, level: level_two }
  let(:level_one) { create :level, :one }
  let(:level_two) { create :level, :two }

  # This policy relies on being supplied a `current_user`, which would have `current_founder` set.
  def current_user(founder)
    founder.user.tap { |user| user.current_founder = founder }
  end

  permissions :connect? do
    context 'when faculty belongs to level 1' do
      let(:faculty) { build :faculty, level: level_one }

      it 'denies access to public' do
        expect(subject).to_not permit(nil, faculty)
      end

      it 'denies access to level 0 team-lead' do
        expect(subject).to_not permit(current_user(level_0_startup.team_lead), faculty)
      end

      it 'grants access to level 1 team-lead' do
        expect(subject).to permit(current_user(level_1_startup.team_lead), faculty)
      end

      it 'denies access to level 1 non-team-lead' do
        non_admin = level_1_startup.founders.find { |founder| !founder.team_lead? }
        expect(subject).to_not permit(current_user(non_admin), faculty)
      end

      it 'grants access to level 2 team-lead' do
        expect(subject).to permit(current_user(level_2_startup.team_lead), faculty)
      end
    end

    context 'when faculty belongs to level 2' do
      let(:faculty) { build :faculty, level: level_two }

      it 'denies access to level 1 team lead' do
        expect(subject).to_not permit(current_user(level_1_startup.team_lead), faculty)
      end

      it 'grants access to level 2 team lead' do
        expect(subject).to permit(current_user(level_2_startup.team_lead), faculty)
      end

      it 'denies access to level 2 non-team-lead' do
        non_admin = level_2_startup.founders.find { |founder| !founder.team_lead? }
        expect(subject).to_not permit(current_user(non_admin), faculty)
      end
    end
  end
end
