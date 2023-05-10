# frozen_string_literal: true

module ApiOnlyPagination
  class Paginate
    attr_reader :page, :count, :per_page

    def initialize(page, per_page, count)
      @page     = (page || ApiOnlyPagination.configuration.default_page).to_i
      @count    = count
      @per_page = [(per_page.to_i || ApiOnlyPagination.configuration.default_page_size),
                   ApiOnlyPagination.configuration.max_per_page].min
    end

    def offset
      return 0 if page == 1

      per_page * (page.to_i - 1)
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
      page == total_pages
    end

    def first_page?
      page == 1
    end

    def total_pages
      (count / per_page.to_f).ceil
    end
  end
end
