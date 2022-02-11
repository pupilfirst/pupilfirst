desc 'Prepare application for asset precompilation'
task before_assets_precompile: [:environment] do
  next unless ENV.key?('PREPARE_FOR_PRECOMPILATION')

  puts 'Generating the locales.json file...'
  system 'bundle exec i18n export'

  puts 'Installing dependencies using yarn...'
  system 'yarn install'

  puts 'Compiling ReScript files...'
  system 'yarn re:build'
end

Rake::Task['assets:precompile'].enhance ['before_assets_precompile']
