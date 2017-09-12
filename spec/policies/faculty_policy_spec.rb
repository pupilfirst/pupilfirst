require 'rails_helper'

describe FacultyPolicy do
  subject { described_class }

  let(:level_0_startup) { create :level_0_startup }
  let(:level_1_startup) { create :startup, :subscription_active }
  let(:level_2_startup) { create :startup, :subscription_active, maximum_level: level_two }
  let(:level_one) { create :level, :one }
  let(:level_two) { create :level, :two }

  permissions :connect? do
    context 'when faculty belongs to level 1' do
      let(:faculty) { build :faculty, level: level_one }

      it 'denies access to public' do
        expect(subject).to_not permit(nil, faculty)
      end

      it 'denies access to level 0 team-lead' do
        expect(subject).to_not permit(level_0_startup.team_lead.user, faculty)
      end

      it 'grants access to max level 1 team-lead' do
        expect(subject).to permit(level_1_startup.team_lead.user, faculty)
      end

      it 'denies access to max level 1 non-team-lead' do
        non_admin = level_1_startup.founders.find { |founder| !founder.team_lead? }
        expect(subject).to_not permit(non_admin.user, faculty)
      end

      it 'grants access to max level 2 team-lead' do
        expect(subject).to permit(level_2_startup.team_lead.user, faculty)
      end
    end

    context 'when faculty belongs to level 2' do
      let(:faculty) { build :faculty, level: level_two }

      it 'denies access to max level 1 team lead' do
        expect(subject).to_not permit(level_1_startup.team_lead.user, faculty)
      end

      it 'grants access to max level 2 team lead' do
        expect(subject).to permit(level_2_startup.team_lead.user, faculty)
      end

      it 'denies access to max level 2 non-team-lead' do
        non_admin = level_2_startup.founders.find { |founder| !founder.team_lead? }
        expect(subject).to_not permit(non_admin.user, faculty)
      end
    end
  end
end
