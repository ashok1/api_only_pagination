# frozen_string_literal: true

require "bundler/setup"
require "api_only_pagination"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
    t.string :role
  end
end

class User < ActiveRecord::Base; end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    User.delete_all
    ApiOnlyPagination.reset
  end
end
