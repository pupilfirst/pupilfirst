module Communities
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, community)
      super(view_context)

      @community = community
    end

    def json_props
      {
        authenticityToken: view.form_authenticity_token,
        questions: questions
      }.to_json
    end

    private

    def questions
      @community.questions.map do |question|
        {
          id: question.id,
          title: question.title,
          description: question.description
        }
      end
    end
  end
end
