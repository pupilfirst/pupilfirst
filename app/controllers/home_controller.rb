class HomeController < ApplicationController
  layout 'demo'

  def index
    @blogs = get_latest_blogs
  end

  private

  def get_latest_blogs
    wp = Rubypress::Client.new(:host => "startatsv.com",:username => "admin",:password => "Startup1#")
    filter_hash = {orderby: "post_date",order: "DESC",post_type: "post",post_status: "publish",number: 4}
    fields_array = ["post_title","post_content","post_thumbnail"]
    wp.getPosts(filter: filter_hash,fields: fields_array)
  end

end

