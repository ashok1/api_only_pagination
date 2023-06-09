# frozen_string_literal: true

require "active_record"

module ApiOnlyPagination
  module ActiveRecordPaginate
    extend ActiveSupport::Concern
    module ClassMethods
      %i[do_paginate paginate paginated_response].each do |access_method|
        define_method(access_method) do |page = ApiOnlyPagination.configuration.default_page, per_page = ApiOnlyPagination.configuration.default_page_size| # or even |*args|
          pagination = ApiOnlyPagination::Pagination.new(all, { page: page, per_page: per_page })
          meta_data = pagination.metadata

          ApiOnlyPagination::PaginatedData
            .new(data: pagination.results,
                 per_page: meta_data.per_page,
                 current_page: meta_data.page,
                 total_pages: meta_data.total_pages,
                 total_records: meta_data.count)
        end
      end 
    end
  end
end
