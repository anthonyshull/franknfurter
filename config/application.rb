require_relative "boot"

require "rails"

require "action_controller/railtie"
require "active_job/railtie"
require "active_model/railtie"
require "active_record/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 8.1

    config.api_only = true
    config.time_zone = "Central Time (US & Canada)"

    config.autoload_paths << Rails.root.join("app", "services")
  end
end
