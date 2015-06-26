class HomeController < ApplicationController
  layout 'demo'

  def index
    @blogs = get_latest_blogs
  end

  private

  def get_latest_blogs
    wp = Rubypress::Client.new(:host => "startatsv.com",:username => ENV['WP_USERNAME'],:password => ENV['WP_PASSWORD'])
    filter_hash = {orderby: "post_date",order: "DESC",post_type: "post",post_status: "publish",number: 4}
    fields_array = ["post_title","post_content","post_thumbnail","link"]
    wp.getPosts(filter: filter_hash,fields: fields_array)
  end

end

