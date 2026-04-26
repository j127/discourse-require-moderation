# frozen_string_literal: true

RSpec.describe NewPostManager do
  fab!(:moderated_user) { Fabricate(:user, username: "moderated_user", trust_level: TrustLevel[1]) }
  fab!(:regular_user) { Fabricate(:user, username: "regular_user", trust_level: TrustLevel[1]) }
  fab!(:topic)

  def manager_for(user)
    NewPostManager.new(
      user,
      raw: "Hello world, this is a long enough post body.",
      topic_id: topic.id,
    )
  end

  describe ".post_needs_approval?" do
    context "when the plugin is disabled" do
      before do
        SiteSetting.discourse_require_moderation_enabled = false
        SiteSetting.discourse_require_moderation_users = "moderated_user"
      end

      it "does not force approval for users that would otherwise be on the list" do
        expect(NewPostManager.post_needs_approval?(manager_for(moderated_user))).to eq(:skip)
      end
    end

    context "when the plugin is enabled" do
      before { SiteSetting.discourse_require_moderation_enabled = true }

      it "forces approval for listed users" do
        SiteSetting.discourse_require_moderation_users = "moderated_user"
        expect(NewPostManager.post_needs_approval?(manager_for(moderated_user))).to eq(:trust_level)
      end

      it "does not affect users that are not on the list" do
        SiteSetting.discourse_require_moderation_users = "moderated_user"
        expect(NewPostManager.post_needs_approval?(manager_for(regular_user))).to eq(:skip)
      end

      it "matches usernames case-insensitively when the setting is uppercased" do
        SiteSetting.discourse_require_moderation_users = "MODERATED_USER"
        expect(NewPostManager.post_needs_approval?(manager_for(moderated_user))).to eq(:trust_level)
      end

      it "matches usernames case-insensitively when the username has different casing" do
        mixed_case = Fabricate(:user, username: "MixedCaseUser", trust_level: TrustLevel[1])
        SiteSetting.discourse_require_moderation_users = "mixedcaseuser"
        expect(NewPostManager.post_needs_approval?(manager_for(mixed_case))).to eq(:trust_level)
      end

      it "ignores surrounding whitespace in the configured list" do
        SiteSetting.discourse_require_moderation_users = "  moderated_user  "
        expect(NewPostManager.post_needs_approval?(manager_for(moderated_user))).to eq(:trust_level)
      end

      it "supports multiple usernames separated by pipes" do
        SiteSetting.discourse_require_moderation_users = "alice|moderated_user|bob"
        expect(NewPostManager.post_needs_approval?(manager_for(moderated_user))).to eq(:trust_level)
      end

      it "skips when the configured list is empty" do
        SiteSetting.discourse_require_moderation_users = ""
        expect(NewPostManager.post_needs_approval?(manager_for(moderated_user))).to eq(:skip)
      end

      it "preserves core approval reasons for unlisted users" do
        SiteSetting.discourse_require_moderation_users = "someone_else"
        SiteSetting.approve_post_count = 1
        # regular_user has 0 approved posts, so core requires approval (:post_count).
        # Our plugin must not clobber that with :skip.
        expect(NewPostManager.post_needs_approval?(manager_for(regular_user))).to eq(:post_count)
      end
    end
  end
end
