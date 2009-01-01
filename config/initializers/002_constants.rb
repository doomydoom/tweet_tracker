LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales"
LOCALES_AVAILABLE = Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
  I18n.load_path << locale_file
  File.basename(File.basename(locale_file, ".yml"), ".yml")
end.uniq.sort