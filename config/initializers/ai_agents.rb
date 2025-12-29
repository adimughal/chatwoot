# frozen_string_literal: true

require 'agents'

Rails.application.config.after_initialize do
  AiAgentsConfig.configure!
rescue StandardError => e
  Rails.logger.error "Failed to configure AI Agents SDK: #{e.message}"
end
