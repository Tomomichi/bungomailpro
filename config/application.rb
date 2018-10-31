require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bungomailpro
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # 表示時のタイムゾーンをJSTに設定
    config.time_zone = 'Asia/Tokyo'
    # DB保存時のタイムゾーンをJSTに設定
    config.active_record.default_timezone = :local

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Don't generate assets and helpers
    config.generators do |g|
      g.assets     false
      g.helper     false
    end

    # Form Error Field
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      %Q(<div class="field error">#{html_tag}</div>).html_safe
    end

    # Set 403 for Pundit NotAuthorized Error
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden
  end
end
