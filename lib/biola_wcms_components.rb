require "biola_wcms_components/version"
require "biola_wcms_components/engine" if defined?(::Rails)
require "ace-rails-ap"
require "buweb_content_models"
require "chronic_ping"
require "pundit"
require "coffee-rails"
require "sass-rails"
require "slim"

module BiolaWcmsComponents
  require 'biola_wcms_components/configuration'

  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
end


autoload :CasAuthentication, 'components/cas_authentication'
autoload :MenuBlock, 'components/menu_block'
autoload :PresentationDataEditor, 'components/presentation_data_editor'
