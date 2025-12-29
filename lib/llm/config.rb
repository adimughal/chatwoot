require 'ruby_llm'

module Llm::Config
  DEFAULT_MODEL = 'gpt-4o-mini'.freeze
  class << self
    def initialized?
      @initialized ||= false
    end

    def initialize!
      current_api_key = system_api_key
      current_endpoint = openai_endpoint

      return if @initialized && @system_api_key == current_api_key && @openai_endpoint == current_endpoint

      configure_ruby_llm
      @initialized = true
      @system_api_key = current_api_key
      @openai_endpoint = current_endpoint
    end

    def reset!
      @initialized = false
    end

    def with_api_key(api_key, api_base: nil)
      context = RubyLLM.context do |config|
        config.openai_api_key = api_key
        config.openai_api_base = api_base
      end

      yield context
    end

    private

    def configure_ruby_llm
      RubyLLM.configure do |config|
        config.openai_api_key = system_api_key
        config.openai_api_base = openai_endpoint&.chomp('/')
        config.logger = Rails.logger
      end
    end

    def system_api_key
      InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
    end

    def openai_endpoint
      InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value
    end
  end
end
