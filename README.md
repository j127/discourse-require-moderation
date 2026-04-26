# discourse-require-moderation

Require moderator approval for posts created by specific Discourse users.

Based on ideas from [discourse-forcemoderation](https://github.com/LeoDavidson/discourse-forcemoderation) but rewritten from scratch in 2026.

## What it does

When the plugin is enabled, it extends Discourse's `NewPostManager` approval checks. If a post would normally bypass approval, this plugin can still send it to the review queue when the posting user's username appears in the configured list.

Username matching is case-insensitive.

## Installation

This plugin is intended for self-hosted Discourse installs running Discourse 3.0 or newer.

Add the repository to the `hooks: after_code:` section of your container config, for example:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/j127/discourse-require-moderation.git
```

Then rebuild the app:

```sh
cd /var/discourse
./launcher rebuild app
```

For the full production plugin workflow, see the official Discourse guide:
<https://meta.discourse.org/t/install-plugins-on-a-self-hosted-site/19157>

## Configuration

After rebuilding:

1. Go to `Admin > Settings > Plugins`.
2. Enable `discourse require moderation enabled`.
3. Add one or more usernames to `discourse require moderation users`.

Posts from matching users will be queued for moderator approval.

## Development

For a local development install, place the plugin inside your Discourse app's `plugins/` directory or symlink it there, then restart Discourse. The official guide is here:
<https://meta.discourse.org/t/install-plugins-in-your-non-docker-development-environment/205337>

This plugin does not ship migrations or front-end assets. Its behavior is implemented in `plugin.rb` by extending the server-side approval pipeline.

## Testing

Run plugin specs from a Discourse test environment with this plugin installed under `plugins/`. This repository does not include a standalone Discourse app, so commands like `bundle exec rspec` from the plugin directory alone are not sufficient unless you are already inside a full Discourse development setup.
