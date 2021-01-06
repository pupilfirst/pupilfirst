class GenerateManifestService
  include RoutesResolvable

  def initialize(school)
    @school = school
  end

  def json
    {
      short_name: @school.name,
      name: @school.name,
      icons: [
        {
          src: url_helpers.rails_representation_url(icon_variant(:sm), only_path: true),
          sizes: "100x100",
          type: "image/png"
        },
        {
          src: url_helpers.rails_representation_url(icon_variant(:md), only_path: true),
          sizes: "144x144",
          type: "image/png"
        },
        {
          src: url_helpers.rails_representation_url(icon_variant(:lg), only_path: true),
          sizes: "192x192",
          type: "image/png"
        },
        {
          src: url_helpers.rails_representation_url(icon_variant(:xl3), only_path: true),
          sizes: "512x512",
          type: "image/png"
        },
      ],
      start_url: "/dashboard",
      display: "standalone",
      scope: "/",
      background_color: "#4D1E9A",
      theme_color: "#4D1E9A",
    }
  end


  private

  def icon_variant(variant)
    icon = @school.icon
    case variant
      when :sm
        icon.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '100x100>'
          })
      when :md
        icon.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '144x144>'
          })
      when :lg
        icon.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '192x192>'
          })
      when :xl3
        icon.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '512x512>'
          })
      else
        icon
    end
  end
end

