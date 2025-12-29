# frozen_string_literal: true

module AiAgentsConfig
  class << self
    def configure!
      api_key = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
      model = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value.presence || LlmConstants::DEFAULT_MODEL
      api_endpoint = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value || LlmConstants::OPENAI_API_ENDPOINT

      return cache_config(api_key, api_endpoint, model) unless api_key.present?
      return if unchanged?(api_key, api_endpoint, model)

      Agents.configure do |config|
        config.openai_api_key = api_key
        config.openai_api_base = build_api_base(api_endpoint)
        config.default_model = model
        config.debug = false
      end

      cache_config(api_key, api_endpoint, model)
    end

    private

    def cache_config(api_key, api_endpoint, model)
      @api_key = api_key
      @api_endpoint = api_endpoint
      @model = model
    end

    def unchanged?(api_key, api_endpoint, model)
      @api_key == api_key && @api_endpoint == api_endpoint && @model == model
    end

    def build_api_base(api_endpoint)
      return nil if api_endpoint.blank?

      "#{api_endpoint.chomp('/')}/v1"
    end
  end
end
