# frozen_string_literal: true

# Main module
module ApiOnlyPagination
  # Response object class
  class PaginatedData
    attr_accessor :data,
                  :per_page,
                  :current_page,
                  :total_pages,
                  :total_records
  end
end
