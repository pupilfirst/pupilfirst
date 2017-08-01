class TalentController < ApplicationController
  before_action :skip_container

  layout 'application_v2'

  # GET /talent
  def index
    @talent_form = TalentForm.new(OpenStruct.new)
  end

  # POST /talent/contact
  def contact
    @talent_form = TalentForm.new(OpenStruct.new)

    if verify_recaptcha
      if @talent_form.validate(talent_form_params)
        @talent_form.send_mail
        flash[:success] = "An email with your query has been sent to help@sv.co. We'll get back to you as soon as we can."
        redirect_to talent_path
      else
        flash.now[:error] = 'Please make sure that you filled out all required fields in the form.'
        @show_form = true
        render 'index'
      end
    else
      # flash.now[:error] = 'The Recaptcha check failed. Please click on the Recaptcha verification before submitting the form.'
      @show_form = true
      render 'index'
    end
  end

  private

  def skip_container
    @skip_container = true
  end

  def talent_form_params
    params.require(:talent).permit(:name, :email, :mobile, :organization, :website, query_type: [])
  end
end
