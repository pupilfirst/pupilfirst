json.array! @startups do |startup|
  json.(startup, :id, :name, :logo_url, :pitch, :website)
  json.created_at     fmt_time(startup.created_at)
end
