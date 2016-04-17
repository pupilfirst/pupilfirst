ActiveAdmin.register_page 'Short URLs' do
  menu parent: 'Dashboard'

  content do
    if params[:shortened].present?
      shortened_url = Shortener::ShortenedUrl.find_by url: params[:shortened]
      render 'submitted_url_result', shortened_url: shortened_url
    end

    render 'form'

    table_for Shortener::ShortenedUrl.order('created_at DESC').limit(10), class: 'aa-short-urls-table' do
      caption "10 most recent shortened URL-s (of #{Shortener::ShortenedUrl.count} total)"

      column :url

      column :short_url do |short_url|
        url = "https://sv.co/#{short_url.unique_key}"
        link_to url, url
      end
    end
  end

  page_action :shorten, method: :post do
    url_to_shorten = params.dig(:short_urls, :url)
    shortened_url = Shortener::ShortenedUrl.new url: url_to_shorten

    shortened_url = if shortened_url.valid?
      Shortener::ShortenedUrl.generate url_to_shorten
    end

    redirect_to admin_short_urls_url(shortened: shortened_url&.url)
  end
end
