# frozen_string_literal: true

# name: discourse-require-moderation
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_require_moderation_enabled

module ::DiscourseRequireModeration
  PLUGIN_NAME = "discourse-require-moderation"
end

require_relative "lib/discourse_require_moderation/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end
