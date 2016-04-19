class HomeController < ApplicationController
  def index
    @large_header_class = 'home-index'
    @skip_container = true
    @sitewide_notice = params[:redirect_from] == 'startupvillage.in'
  end

  def apply
    batch = params[:batch] || 'default'
    @skip_container = true

    raise_not_found unless %w(default 3).include?(batch)

    render "home/apply/batch-#{batch}"
  end

  def transparency
    @skip_container = true
  end

  def graduation
    @skip_container = true

    @contact_form = ContactForm.new
  end

  # used by the 'shortener' gem's config
  def not_found
    raise_not_found
  end

  private

  # def contact_form_params
  #   params.require(:contact_form).permit(:name, :email, :mobile)
  # end
end
