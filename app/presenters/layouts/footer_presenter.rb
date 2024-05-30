module Layouts
  class FooterPresenter < ApplicationPresenter
    def student?
      true
    end

    def nav_links
      SchoolLink
        .where(school: current_school, kind: SchoolLink::KIND_FOOTER)
        .order(:sort_index)
        .map { |sl| { title: sl.title, url: sl.url, custom: true } }
    end

    def social_links
      @social_links ||=
        SchoolLink
          .where(school: current_school, kind: SchoolLink::KIND_SOCIAL)
          .order(:sort_index)
          .map { |sl| { title: sl.title, url: sl.url } }
    end

    def school_name
      current_school.name
    end

    def logo_image_tag(background)
      logo = background == :dark ? :logo_on_dark_bg : :logo_on_light_bg

      if current_school.public_send(logo).attached?
        logo_url =
          view.rails_public_blob_url(
            current_school.logo_variant(:mid, background: background)
          )

        view.image_tag(
          logo_url,
          class: "w-25 #{logo}",
          alt:
            I18n.t(
              "presenters.layouts.footer.logo_alt",
              school_name: current_school.name
            )
        )
      else
        view.content_tag(:span, current_school.name, class: "#{logo}")
      end
    end

    def logo?
      current_school.logo_on_dark_bg.attached?
    end

    def logo_url
      view.rails_public_blob_url(
        current_school.logo_variant(:mid, background: :light)
      )
    end

    def social_icon(title)
      %w[
        facebook
        twitter
        instagram
        youtube
        linkedin
        snapchat
        tumblr
        pinterest
        reddit
        flickr
      ].each { |key| return "fab fa-#{key}" if key.in?(title) }

      "fas fa-users"
    end

    def address
      @address ||=
        begin
          raw_address = SchoolString::Address.for(current_school)

          if raw_address.present?
            parser =
              MarkdownIt::Parser
                .new(:commonmark)
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

    def code_of_conduct?
      SchoolString::CodeOfConduct.saved?(current_school)
    end
  end
end
