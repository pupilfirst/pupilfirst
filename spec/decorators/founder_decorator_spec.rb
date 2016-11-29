require 'rails_helper'

describe FounderDecorator do
  let(:founder) { create :founder }
  subject { founder.decorate }

  describe '#identification_proof_hint' do
    context 'when founder does not have identification proof' do
      it 'returns simple hint' do
        expect(subject.identification_proof_hint).to eq('Must be one of Aadhaar Card / Driving License / Passport / Voters ID')
      end
    end

    context 'when founder has identification proof' do
      let(:college_id_path) { File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg')) }
      let(:founder) { create :founder, identification_proof: File.open(college_id_path) }

      it "returns hint with existing file's name" do
        expect(subject.identification_proof_hint).to eq('Choose another file if you wish to replace <code>college_id.jpg</code><br/>Must be one of Aadhaar Card / Driving License / Passport / Voters ID')
      end
    end
  end
end
