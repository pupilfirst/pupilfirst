module Schools
  class CustomizePresenter < ApplicationPresenter
    def json_props
      {
        authenticityToken: view.form_authenticity_token
      }.to_json
    end
  end
end
