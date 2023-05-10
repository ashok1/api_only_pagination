# frozen_string_literal: true

require "active_record"
require_relative "api_only_pagination/version"
require_relative "api_only_pagination/configuration"
require_relative "api_only_pagination/paginate"
require_relative "api_only_pagination/pagination"
require_relative "api_only_pagination/paginated_data"

module ApiOnlyPagination
  def paginate(page, per_page)
    pagination = ApiOnlyPagination::Pagination.new(self, { page: page, per_page: per_page })
    meta_data = pagination.metadata
    ApiOnlyPagination::PaginatedData
      .new(data: pagination.results,
           per_page: per_page,
           current_page: page,
           total_pages: meta_data.total_pages,
           total_records: meta_data.count)
  end

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
  include ApiOnlyPagination
end
