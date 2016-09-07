desc 'Import colleges from URL'
task import_colleges: [:environment] do
  CollegeImporterService.new(ENV['IMPORT_URL']).process
end
