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
        { src: icon_src(:sm), sizes: '100x100', type: 'image/png' },
        { src: icon_src(:md), sizes: '144x144', type: 'image/png' },
        { src: icon_src(:lg), sizes: '192x192', type: 'image/png' },
        { src: icon_src(:xl3), sizes: '512x512', type: 'image/png' }
      ],
      start_url: '/dashboard',
      display: 'standalone',
      scope: '/',
      background_color: '#ffffff',
      theme_color: '#4D1E9A'
    }
  end

  private

  def icon_src(variant)
    if icon.present?
      url_helpers.rails_representation_url(
        icon_variant(variant),
        only_path: true
      )
    else
      "/images/pwa/#{default_icon_variant(variant)}.png"
    end
  end

  def icon
    @icon ||= @school.icon
  end

  def default_icon_variant(variant)
    case variant
    when :md
      'pf_md'
    when :lg
      'pf_lg'
    when :xl3
      'pf_3xl'
    when :sm
      'pf_sm'
    end
  end

  def icon_variant(variant)
    case variant
    when :sm
      icon.variant(variant_options('100x100>'))
    when :md
      icon.variant(variant_options('144x144>'))
    when :lg
      icon.variant(variant_options('192x192>'))
    when :xl3
      icon.variant(variant_options('512x512>'))
    else
      icon
    end
  end

  def variant_options(resize)
    { auto_orient: true, gravity: 'center', resize: resize }
  end
end
