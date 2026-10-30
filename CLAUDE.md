# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`api_only_pagination` is a small Ruby gem that adds offset pagination to ActiveRecord models and relations for API-only apps. It returns a plain response object (data + page metadata) instead of view helpers. Requires Ruby >= 3.2 and ActiveRecord >= 6.1.

## Commands

```bash
bin/setup                         # install dependencies
bin/console                       # IRB with the gem loaded
bundle exec rake                  # specs + RuboCop (what CI runs)
bundle exec rubocop               # lint
bundle exec rspec                 # run specs
bundle exec rspec spec/api_only_pagination_spec.rb:13   # single example
bundle exec rake install          # install gem locally
bundle exec rake release          # tag + push to rubygems (bump lib/api_only_pagination/version.rb first)
```

Specs run against an in-memory SQLite database; `spec/spec_helper.rb` defines the schema and a `User` model, and resets records and configuration before each example.

CI (`.github/workflows/ci.yml`) runs specs against every Gemfile in `gemfiles/` (one per ActiveRecord version) on several Rubies. To reproduce one locally: `BUNDLE_GEMFILE=gemfiles/activerecord_7.2.gemfile bundle install && BUNDLE_GEMFILE=gemfiles/activerecord_7.2.gemfile bundle exec rspec`. When adding a Rails version, add a gemfile and a matrix entry.

## Architecture

The call flow spans several small files in `lib/api_only_pagination/`:

1. **Hooking into ActiveRecord** (`lib/api_only_pagination.rb`): an `ActiveSupport.on_load(:active_record)` block includes `ActiveRecordPaginate` into `ActiveRecord::Base`. Chained calls like `User.where(...).do_paginate` still work, because a relation passes unknown methods to its model class while applying its own scope, so `all` inside the method returns the scoped relation.
2. **`ActiveRecordPaginate`**: defines `do_paginate` and its alias `paginated_response`, each taking `(page, per_page)`. (`paginate` was removed in 0.2.0 because it clashes with will_paginate.) They wrap `all` in a `Pagination` and build a `PaginatedData`.
3. **`Pagination`**: runs `collection.count(:all)` once when it's constructed (for grouped relations it counts the groups), then applies `limit`/`offset` from the metadata in `results`. `results` is still a lazy relation.
4. **`Paginate`**: the metadata and normalization logic. Any page/per_page value that isn't a positive integer (nil, zero, negative, non-numeric) falls back to the configured default, and `per_page` is capped at `max_per_page`. It also computes `offset`, `total_pages`, and next/previous helpers.
5. **`PaginatedData`**: holds `data`, `per_page`, `current_page`, `total_pages`, `total_records`, `next_page` and `previous_page`. Its `as_json` defines the public JSON shape documented in the README, and passes serializer options (`only:`, `except:` ...) through to the records only. Changing that shape is a breaking change.

6. **`Controller`** (`render_paginated`): included through `ActiveSupport.on_load(:action_controller)`, so the gem never requires ActionPack itself; ActionPack is only a test dependency. Its methods are private so they can't become routable actions. The optional headers include a `Link` header built from `request.query_parameters`.

**Configuration** (`Configuration` + `ApiOnlyPagination.configure`/`.reset`): `default_page_size` (20), `max_per_page` (100), `default_page` (1), `pagination_headers` (false). Values are read when each call runs, so changes take effect right away.

## Style

RuboCop (`.rubocop.yml`): double-quoted strings, max line length 120, `TargetRubyVersion` 3.2 (so hash shorthand like `{ page:, per_page: }` is the enforced style). Every file starts with `# frozen_string_literal: true`.
