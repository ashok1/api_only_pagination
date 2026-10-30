# frozen_string_literal: true

require "active_record"
require_relative "api_only_pagination/version"
require_relative "api_only_pagination/configuration"
require_relative "api_only_pagination/paginate"
require_relative "api_only_pagination/pagination"
require_relative "api_only_pagination/paginated_data"
require_relative "api_only_pagination/active_record_paginate"

# Offset pagination for ActiveRecord that returns data plus page metadata for API responses
module ApiOnlyPagination
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset
      @configuration = Configuration.new
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ApiOnlyPagination::ActiveRecordPaginate
end
