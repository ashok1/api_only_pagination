## [Unreleased]

## [0.1.5] - 2026-10-30

- Fix: negative `page`/`per_page` values produced invalid SQL; any value that isn't a positive integer now falls back to the configured default
- Fix: paginating relations with `group` or a custom `select` raised errors while counting
- Fix: `last_page?` returned false for empty results and for pages past the end
- Remove a no-op `ActiveRecord::Relation.include`; chained calls such as `User.where(...).do_paginate` are unaffected
- Add a real spec suite (in-memory SQLite) and CI across Ruby 3.2–3.4 and ActiveRecord 6.1–8.1

## [0.1.0] - 2023-03-23

- Initial release
