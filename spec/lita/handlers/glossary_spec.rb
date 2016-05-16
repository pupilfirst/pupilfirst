require 'rails_helper'

require_relative '../../../lib/lita/handlers/glossary'

describe Lita::Handlers::Glossary do
  describe '#definition' do
    context "when term isn't specified" do
      let(:response) { double 'Lita Response Object', match_data: %w(define) }

      it 'replies that term is required' do
        expect(response).to receive(:reply).with I18n.t('slack.handlers.glossary.no_term_error')
        subject.definition(response)
      end
    end

    context 'when term is unknown' do
      let(:response) { double 'Lita Response Object', match_data: ['define', 'unknown term'] }

      it 'replies that term is unknown' do
        expect(response).to receive(:reply).with I18n.t('slack.handlers.glossary.term_not_found', term: 'unknown term')
        subject.definition(response)
      end
    end

    context 'when term is known' do
      let(:glossary_term) { create :glossary_term, term: 'known term', definition: Faker::Lorem.sentence }
      let(:response) { double 'Lita Response Object', match_data: ['define', 'known term'] }

      it 'replies with definition to term' do
        expect(response).to receive(:reply).with <<~DEFINITION
          > *Definition of known term:*
          #{glossary_term.definition}
        DEFINITION

        subject.definition(response)
      end
    end
  end
end
