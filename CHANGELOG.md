## [Unreleased]

## [0.2.0] - 2026-10-30

- **Breaking:** require Ruby >= 3.2 and ActiveRecord >= 6.1 (the versions CI tests)
- **Breaking:** remove the `paginate` alias, which clashed with will_paginate; use `do_paginate` or `paginated_response`
- Add `next_page` and `previous_page` to the response
- Add `PaginatedData#to_h` and an explicit `#as_json`; serializer options such as `only:` apply to the records in `data`
- Add `render_paginated` controller helper (ActionController::Base and ::API) that reads `page`/`per_page` from params, with opt-in `X-Total-Count`/`Link` pagination headers (`pagination_headers` setting)
- Note: Rails 8.1 does not load on Ruby 3.3.0 because of a Ruby parser bug fixed in 3.3.1; use a later 3.3.x

## [0.1.5] - 2026-10-30

- Fix: negative `page`/`per_page` values produced invalid SQL; any value that isn't a positive integer now falls back to the configured default
- Fix: paginating relations with `group` or a custom `select` raised errors while counting
- Fix: `last_page?` returned false for empty results and for pages past the end
- Remove a no-op `ActiveRecord::Relation.include`; chained calls such as `User.where(...).do_paginate` are unaffected
- Add a real spec suite (in-memory SQLite) and CI across Ruby 3.2–3.4 and ActiveRecord 6.1–8.1

## [0.1.0] - 2023-03-23

- Initial release
