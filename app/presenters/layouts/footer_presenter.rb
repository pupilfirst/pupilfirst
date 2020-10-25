module Layouts
  class FooterPresenter < ApplicationPresenter
    def student?
      true
    end

    def nav_links
      footer_links = current_user.present? ? [{ title: 'Home', url: '/' }, { title: 'Dashboard', url: '/dashboard' }] : []

      custom_links = SchoolLink.where(
        school: current_school,
        kind: SchoolLink::KIND_FOOTER
      ).map { |sl| { title: sl.title, url: sl.url, custom: true } }

      footer_links + custom_links
    end

    def social_links
      @social_links ||= SchoolLink.where(
        school: current_school,
        kind: SchoolLink::KIND_SOCIAL
      ).map { |sl| { title: sl.title, url: sl.url } }.reverse
    end

    def school_name
      current_school.name
    end

    def logo?
      current_school.logo_on_dark_bg.attached?
    end

    def logo_url
      view.url_for(current_school.logo_variant(:mid, background: :light))
    end

    def social_icon(title)
      %w[facebook twitter instagram youtube linkedin snapchat tumblr pinterest reddit flickr].each do |key|
        if key.in?(title)
          return "fab fa-#{key}"
        end
      end

      'fas fa-users'
    end

    def address
      @address ||= begin
        raw_address = SchoolString::Address.for(current_school)

        if raw_address.present?
          parser = MarkdownIt::Parser.new(:commonmark)
            .use(MotionMarkdownItPlugins::Sub)
            .use(MotionMarkdownItPlugins::Sup)

          parser.render(raw_address)
        end
      end
    end

    def email_address
      @email_address ||= SchoolString::EmailAddress.for(current_school)
    end

    def privacy_policy?
      SchoolString::PrivacyPolicy.saved?(current_school)
    end

    def terms_and_conditions?
      SchoolString::TermsAndConditions.saved?(current_school)
    end
  end
end
