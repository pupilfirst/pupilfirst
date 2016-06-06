require 'rails_helper'

require_relative '../../../lib/lita/handlers/changelog'

describe Lita::Handlers::ChangeLog do
  let(:response) { double 'Lita Response Object' }
  context 'when user asks for changelog' do
    it 'sends the latest changelog' do
      expect(response).to receive(:reply).with(/Here are the latest changes on the SV.CO platform/)
      subject.changelog response
    end
  end
end
