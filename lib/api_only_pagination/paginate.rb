# frozen_string_literal: true

module ApiOnlyPagination
  # Normalizes page/per_page input and computes page metadata from a record count
  class Paginate
    attr_reader :page, :count, :per_page

    def initialize(page, per_page, count)
      config    = ApiOnlyPagination.configuration
      @page     = positive_integer(page) || config.default_page
      @count    = count
      @per_page = [positive_integer(per_page) || config.default_page_size, config.max_per_page].min
    end

    def offset
      per_page * (page - 1)
    end

    def next_page
      page + 1 unless last_page?
    end

    def next_page?
      page < total_pages
    end

    def previous_page
      page - 1 unless first_page?
    end

    def previous_page?
      page > 1
    end

    def last_page?
      page >= total_pages
    end

    def first_page?
      page == 1
    end

    def total_pages
      (count / per_page.to_f).ceil
    end

    private

    # nil, zero, negative and non-numeric values (e.g. "abc") all become nil
    def positive_integer(value)
      integer = value.to_i
      integer if integer.positive?
    end
  end
end
