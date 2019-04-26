module Layouts
  class FooterPresenter < ApplicationPresenter
    def student?
      true
    end

    def nav_links
      footer_links = [{ title: 'Home', url: '/' }]

      custom_links = SchoolLink.where(
        school: current_school,
        kind: SchoolLink::KIND_FOOTER
      ).map { |sl| { title: sl.title, url: sl.url } }

      footer_links + custom_links
    end

    def social_links
      @social_links ||= SchoolLink.where(
        school: current_school,
        kind: SchoolLink::KIND_SOCIAL
      ).map { |sl| { title: sl.title, url: sl.url } }
    end

    def school_name
      @school_name ||= current_school.name
    end

    def logo?
      current_school.logo_on_dark_bg.attached?
    end

    def logo_url
      view.url_for(current_school.logo_variant(:mid, background: :dark))
    end

    # TODO: Write a better way to decide which icon to present
    def social_icon(url)
      %w[facebook twitter instagram youtube].each do |key|
        if key.in?(url)
          return "fa-#{key}"
        end
      end

      'fa-users'
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
      @email_address ||= begin
        SchoolString::EmailAddress.for(current_school)
      end
    end

    def privacy_policy?
      SchoolString::PrivacyPolicy.saved?(current_school)
    end

    def terms_of_use?
      SchoolString::TermsOfUse.saved?(current_school)
    end
  end
end
