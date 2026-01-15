# frozen_string_literal: true

# name: discourse-require-moderation
# about: Requires moderation for specific users
# version: 0.0.1
# authors: @j127
# url: https://github.com/j127/discourse-require-moderation
# required_version: 2.7.0

enabled_site_setting :discourse_require_moderation_enabled

module ::DiscourseRequireModeration
  PLUGIN_NAME = "discourse-require-moderation"
end

require_relative "lib/discourse_require_moderation/engine"

after_initialize do

  module ::DiscourseRequireModeration
    def post_needs_approval?(manager)
      super_result = super
      return super_result if !SiteSetting.discourse_require_moderation_enabled || super_result != :skip

      users = SiteSetting.discourse_require_moderation_users
      return :skip if users.blank?

      users = users.split("|") if users.is_a?(String)

      if users.is_a?(Array)
        lowercased_username = manager.user.username.downcase
        return :trust_level if users.map { |u| u.strip.downcase }.include?(lowercased_username)
      end
      :skip
    end
  end

  NewPostManager.singleton_class.prepend(::DiscourseRequireModeration)
end
