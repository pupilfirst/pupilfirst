after 'development:startups' do
  startup = Startup.find_by name: 'Super Startup'

  DbConfig.create!(
    key: :featured_startup_id,
    value: startup.id
  )
end
