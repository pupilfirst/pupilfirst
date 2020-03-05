module Layouts
  class FooterPresenter < ApplicationPresenter
    def student?
      true
    end

    def nav_links
      footer_links = current_user.present? ? [{ title: 'Home', url: '/home' }] : []

      return footer_links if current_school.blank?

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
      ).map { |sl| { title: sl.title, url: sl.url } }.reverse
    end

    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'Pupilfirst'
    end

    def logo?
      return true if current_school.blank?

      current_school.logo_on_dark_bg.attached?
    end

    def logo_url
      if current_school.present?
        view.url_for(current_school.logo_variant(:mid, background: :light))
      else
        view.image_url('shared/pupilfirst-logo.svg')
      end
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
        if current_school.present?
          raw_address = SchoolString::Address.for(current_school)

          if raw_address.present?
            parser = MarkdownIt::Parser.new(:commonmark)
              .use(MotionMarkdownItPlugins::Sub)
              .use(MotionMarkdownItPlugins::Sup)

            parser.render(raw_address)
          end
        else
          view.t('presenters.layouts.footer.address_html')
        end
      end
    end

    def email_address
      @email_address ||= begin
        if current_school.present?
          SchoolString::EmailAddress.for(current_school)
        else
          view.t('presenters.layouts.footer.email_address')
        end
      end
    end

    def privacy_policy?
      return true if current_school.blank?

      SchoolString::PrivacyPolicy.saved?(current_school)
    end

    def terms_of_use?
      return true if current_school.blank?

      SchoolString::TermsOfUse.saved?(current_school)
    end
  end
end
