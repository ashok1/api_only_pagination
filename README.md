# ApiOnlyPagination
Lightweight pagination gem that works only with Activerecord for Api only applications
 ## Installation
To install this gem,
```
   $ gem install api_only_pagination
```
or add it to your Gemfile
```
   gem 'api_only_pagination'
```
## Requirements

Ruby 3.2+ and ActiveRecord 6.1+. Versions 0.1.x support older Rubies and Rails but are no longer maintained.

## Usage

Optionally configure defaults in `config/initializers/api_only_pagination.rb`:

```ruby
ApiOnlyPagination.configure do |config|
  config.default_page_size = 20  # per_page when none (or an invalid value) is given
  config.max_per_page = 100      # upper limit for per_page
  config.default_page = 1        # page when none (or an invalid value) is given
end
```

Call `do_paginate(page, per_page)` on any model or relation:

```ruby
result = User.where(active: true).order(:id).do_paginate(params[:page], params[:per_page])
render json: result
```

`page` and `per_page` can come straight from request params. Strings are converted to integers, any value that isn't a positive integer falls back to the configured default, and `per_page` is capped at `max_per_page`.

`do_paginate` returns an `ApiOnlyPagination::PaginatedData` object. It renders as:

```json
{
  "data": [{ "id": 3, "name": "..." }, { "id": 4, "name": "..." }],
  "per_page": 2,
  "current_page": 2,
  "total_pages": 3,
  "total_records": 5,
  "next_page": 3,
  "previous_page": 1
}
```

`next_page` and `previous_page` are `null` on the last and first page. Serializer options apply to the records, so `render json: result, only: [:id, :name]` limits the fields in `data` and keeps the pagination fields. Use `result.to_h` for a symbol-keyed hash, or read the attributes directly (`result.data`, `result.total_pages`, ...).

### Upgrading from 0.1.x

- The `paginate` alias was removed because it clashes with will_paginate. Use `do_paginate` (or `paginated_response`).
- The response has two new fields, `next_page` and `previous_page`.

## Development

After checking out the repo, run `bin/setup` to install dependencies, then `bundle exec rake` to run the specs and RuboCop. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ashok1/api_only_pagination. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ashok1/api_only_pagination/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApiOnlyPagination project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ashok1/api_only_pagination/blob/main/CODE_OF_CONDUCT.md).
