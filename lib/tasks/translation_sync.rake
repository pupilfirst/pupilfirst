namespace :translations do
  desc 'Synchronize missing translation keys from en to specified language'
  task :sync, [:locale] => :environment do |_task, args|
    source_locale = 'en'
    target_locale = args[:locale]

    source_file_path = file_path_for(source_locale)
    target_file_path = file_path_for(target_locale)

    if target_locale.blank?
      puts "Please specify a target language code. Example: rails translations:sync[ar]"
    elsif File.exist?(source_file_path) && File.exist?(target_file_path)
      source_translations = YAML.load_file(source_file_path)
      target_translations = YAML.load_file(target_file_path)

      missing_keys = locale_diff(source_translations[source_locale], target_translations[target_locale])
      target_translations[target_locale].deep_merge!(missing_keys)

      File.open(target_file_path, 'w') { |file| file.write(target_translations.to_yaml(line_width: -1).gsub(/^---\s*\n/, '')) }
      puts "Synchronized missing keys from #{source_locale} to #{target_locale}."
    else
      puts "Translation files not found for #{source_locale} and/or #{target_locale}."
    end
  end

  def locale_diff(source, destination)
    return source unless destination.is_a?(source.class)
    return {} unless source.is_a?(Hash)

    source.each_with_object({}) do |(key, val), diff|
      res = locale_diff(val, destination[key])
      diff[key] = res if res.present?
    end
  end

  def file_path_for(locale)
    Rails.root.join('config', 'locales', "#{locale}.yml")
  end
end
