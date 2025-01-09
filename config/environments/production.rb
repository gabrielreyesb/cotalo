require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.assets.compile = true
  config.active_storage.service = :local
  config.force_ssl = true
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: 'your-app-domain.com', port: 3000 }
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.public_file_server.enabled = true
  config.assets.digest = true
  config.action_dispatch.x_sendfile_header = nil
  config.serve_static_files = true
  config.asset_host = ENV['ASSET_HOST'] if ENV['ASSET_HOST']
  config.assets.css_compressor = :sass
  config.assets.js_compressor = Terser::Compressor.new(
    mangle: true,
    compress: true,
    harmony: true
  )
  config.assets.paths << Rails.root.join('node_modules')
end
