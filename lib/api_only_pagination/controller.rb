# frozen_string_literal: true

module ApiOnlyPagination
  # Controller helper, included into ActionController::Base and ActionController::API on load
  module Controller
    private

    # Paginates scope with page/per_page from params, renders it as JSON and returns the PaginatedData.
    # Remaining options go to render, e.g. render_paginated(User.all, only: [:id, :name], status: :ok)
    def render_paginated(scope, page: params[:page], per_page: params[:per_page],
                         pagination_headers: ApiOnlyPagination.configuration.pagination_headers, **render_options)
      result = scope.do_paginate(page, per_page)
      add_pagination_headers(result) if pagination_headers
      render(json: result, **render_options)
      result
    end

    def add_pagination_headers(result)
      {
        "X-Total-Count" => result.total_records,
        "X-Total-Pages" => result.total_pages,
        "X-Per-Page" => result.per_page,
        "X-Page" => result.current_page,
        "Link" => pagination_link_header(result).presence
      }.compact.each { |name, value| response.headers[name] = value.to_s }
    end

    def pagination_link_header(result)
      return "" if result.total_pages.zero?

      { first: 1, prev: result.previous_page, next: result.next_page, last: result.total_pages }
        .filter_map { |rel, page| %(<#{pagination_url(page, result.per_page)}>; rel="#{rel}") if page }
        .join(", ")
    end

    def pagination_url(page, per_page)
      query = request.query_parameters.merge("page" => page, "per_page" => per_page).to_query
      "#{request.base_url}#{request.path}?#{query}"
    end
  end
end
