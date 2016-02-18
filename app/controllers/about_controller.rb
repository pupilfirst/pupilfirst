class AboutController < ApplicationController
  rescue_from ActionView::MissingTemplate, with: -> { raise_not_found }

  # GET /about
  def index
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
  end

  # GET /about/slack
  def slack
  end

  # GET /about/leaderboard
  def leaderboard
  end

  # GET /about/press-kit
  def media_kit
    @media_kit_url = 'https://drive.google.com/folderview?id=0B9--SdQuJvHpfjJiam1nTnJCNnVIYkY2NVFXWTQwbXNpWUFoQU1oc1RZSHJraG4yb2Y1cDA&usp=sharing'
  end

  # GET /about/contact
  def contact
    @contact_form = ContactForm.new(founder: current_founder)
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
  end

  # POST /about/contact
  def send_contact_email
    @contact_form = ContactForm.new contact_form_params

    # Check recaptcha first.
    unless verify_recaptcha(model: @contact_form)
      render 'contact'
      return
    end

    if @contact_form.save
      flash[:success] = "An email with your query has been sent to help@sv.co. We'll get back to you as soon as we can."
      redirect_to about_contact_path
    else
      flash.now[:error] = 'Please make sure that you filled out all required fields in the contact form.'
      render 'contact'
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:name, :email, :mobile, :company, :query_type, :query)
  end
end
