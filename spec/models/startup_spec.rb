require 'rails_helper'

describe Startup do
  subject { create :startup }

  context 'when attempting to destroy a startup' do
    let(:startup) { create :startup }

    it 'cannot be destroyed if it has founders' do
      create :founder, startup: startup

      expect { startup.destroy! }.to raise_error(
        ActiveRecord::RecordNotDestroyed
      )
    end
  end
end
