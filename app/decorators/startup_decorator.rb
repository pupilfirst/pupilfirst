class StartupDecorator < Draper::Decorator
  delegate_all

  def identicon_logo
    base64_logo = Startups::IdenticonLogoService.new(model).base64_svg
    h.image_tag("data:image/svg+xml;base64,#{base64_logo}", class: 'startup-logo')
  end
end
