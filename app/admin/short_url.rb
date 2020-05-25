ActiveAdmin.register_page 'Short URLs' do
  menu parent: 'Dashboard'

  content do
    if params[:shorten].present?
      expires_at = params[:expires_at].present? ? Time.parse(params[:expires_at]) : nil

      shortened_url = ShortenedUrls::ShortenService.new(
        params[:shorten],
        unique_key: params[:unique_key],
        expires_at: expires_at
      ).shortened_url

      render 'submitted_url_result', shortened_url: shortened_url
    end

    render 'form', form: Admin::ShortenUrlForm.new(ShortenedUrl.new)

    table_for ShortenedUrl.order('created_at DESC').limit(10), class: 'aa-short-urls-table' do
      caption "10 most recent shortened URL-s (of #{ShortenedUrl.count} total)"

      column :url

      column :short_url do |short_url|
        url = "https://sv.co/r/#{short_url.unique_key}"
        link_to url, url
      end
    end
  end

  page_action :shorten, method: :post do
    form = Admin::ShortenUrlForm.new(ShortenedUrl.new)

    # Normalize the incoming URL.
    params[:admin_shorten_url][:url] = Addressable::URI.parse(params[:admin_shorten_url][:url]).normalize.to_s

    if form.validate(params[:admin_shorten_url])
      parameters = { shorten: form.url }
      parameters[:unique_key] = form.unique_key if form.unique_key.present?
      parameters[:expires_at] = form.expires_at if form.expires_at.present?
      redirect_to admin_short_urls_url(parameters)
    else
      render '_form', locals: { form: form }
    end
  end
end
