# frozen_string_literal: true

require "active_record"

module ApiOnlyPagination
  # Adds do_paginate (and its aliases) to every ActiveRecord model and, through delegation, to relations
  module ActiveRecordPaginate
    extend ActiveSupport::Concern

    # Pagination entry points available on models and relations
    module ClassMethods
      %i[do_paginate paginate paginated_response].each do |access_method|
        # nil page/per_page fall back to the configured defaults in Paginate
        define_method(access_method) do |page = nil, per_page = nil|
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
