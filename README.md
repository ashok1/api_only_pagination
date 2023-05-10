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
## Usage

Configure your pagination adding api_only_pagination.rb file in config/initializers unless it will take default configurations.
 
 ```
 ApiOnlyPagination.configure do |config|
   config.default_page_size = 3
   config.max_per_page = 100
   config.default_page = 1
 end
 ```

 Now you can call chain .do_paginate(page, per_page) to your activerecord query.
```
 response = User.do_paginate(1,20)
 ```

 The response will be 

      
         { 
         "data" => [], 
         "per_page" => 3,
         "current_page" => 1,
         "total_pages" => 2,
         "total_records" => 5
         }
         


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_only_pagination. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/api_only_pagination/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApiOnlyPagination project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/api_only_pagination/blob/master/CODE_OF_CONDUCT.md).
