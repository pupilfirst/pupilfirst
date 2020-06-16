require 'rails_helper'

describe ApplicationController do
  describe '#current_school' do
    let!(:first_school) { create :school }
    let!(:second_school) { create :school }
    let!(:third_school) { create :school }

    let!(:second_school_domain) { create :domain, :primary, fqdn: 'www.second.localhost', school: second_school }
    let!(:third_school_domain) { create :domain, :primary, fqdn: 'www.third.localhost', school: third_school }

    context 'when multitenancy is turned on' do
      before do
        Rails.application.secrets.multitenancy = true
      end

      context 'when the current domain belongs to second school' do
        controller do
          def current_domain
            Domain.find_by(fqdn: 'www.second.localhost')
          end
        end

        it 'returns the second school' do
          expect(subject.current_school).to eq(second_school)
        end
      end

      context 'when the current domain belongs to the third school' do
        controller do
          def current_domain
            Domain.find_by(fqdn: 'www.third.localhost')
          end
        end

        it 'returns the third school' do
          expect(subject.current_school).to eq(third_school)
        end
      end
    end

    context 'when multitenancy is turned off' do
      before do
        Rails.application.secrets.multitenancy = false
      end

      it 'returns the first school' do
        expect(subject.current_school).to eq(first_school)
      end
    end
  end
end
