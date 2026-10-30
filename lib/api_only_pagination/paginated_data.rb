# frozen_string_literal: true

# Main module
module ApiOnlyPagination
  # Response object returned by do_paginate; serializes to the documented JSON shape
  class PaginatedData
    attr_accessor :data,
                  :per_page,
                  :current_page,
                  :total_pages,
                  :total_records,
                  :next_page,
                  :previous_page

    def initialize(data:, per_page:, current_page:, total_pages:, total_records:, next_page: nil, previous_page: nil) # rubocop:disable Metrics/ParameterLists
      @data = data
      @per_page = per_page
      @current_page = current_page
      @total_pages = total_pages
      @total_records = total_records
      @next_page = next_page
      @previous_page = previous_page
    end

    def to_h
      {
        data:,
        per_page:,
        current_page:,
        total_pages:,
        total_records:,
        next_page:,
        previous_page:
      }
    end

    # Serializer options (only:, except:, include:, methods:) apply to the records in data,
    # so `render json: result, only: [:id, :name]` works as it would for the bare relation.
    def as_json(options = nil)
      to_h.merge(data: data.as_json(options)).as_json
    end
  end
end
