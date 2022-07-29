module FilterUtils
  include ActiveSupport::Concern

  def filter
    @filter ||=
      URI.decode_www_form(filter_string.presence || '').to_h.symbolize_keys
  end

  def id_from_filter_value(string)
    return unless string

    # Extract the ID from the filter value string, which is in the form of 'id;name_of_the_object
    # e.g. '123;1, Getting Started with Regular Expressions'
    string[/(?<id>.+?);/, 'id']
  end
end
