# frozen_string_literal: true

require_relative "api_only_pagination/version"
require_relative "api_only_pagination/configuration"
require_relative "api_only_pagination/paginate"
require_relative "api_only_pagination/pagination"

module ApiOnlyPagination
  def paginated_response(collection,
                         page = ApiOnlyPagination.configuration.default_page,
                         per_page = ApiOnlyPagination.configuration.default_page_size)
    pagination = ApiOnlyPagination::Pagination.new(collection, { page: page, per_page: per_page })
    meta_data = pagination.metadata
    meta_data.as_json.merge({ data: pagination.results })
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
