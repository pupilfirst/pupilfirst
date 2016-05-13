module Lita
  module Handlers
    class Glossary < Handler
      route(/\Adefine *(\w*) *\?\z/, :definition, command: true, help: { 'define [TERM]?' => I18n.t('slack.help.glossary') })

      def definition(response)
        @response = response
        @term = response.match_data[1].present? ? response.match_data[1] : nil

        @term.present? ? fetch_definition : send_no_term_error
      end

      def fetch_definition
        ActiveRecord::Base.connection_pool.with_connection do
          @result = ::GlossaryTerm.find_by(term: @term.downcase)
        end

        @result.present? ? send_definition : send_not_found
      end

      def send_no_term_error
        @response.reply I18n.t('slack.handlers.glossary.no_term_error')
      end

      def send_not_found
        @response.reply I18n.t('slack.handlers.glossary.term_not_found', term: @term)
      end

      def send_definition
        @response.reply <<~DEFINITION
          > *Definition of #{@term}:*
          #{@result.definition}
        DEFINITION
      end
    end

    Lita.register_handler(Glossary)
  end
end
