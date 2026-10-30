# frozen_string_literal: true

module ApiOnlyPagination
  # Counts a relation and applies limit/offset for the requested page
  class Pagination
    attr_reader :collection, :params

    def initialize(collection, params = {})
      @collection = collection
      @params = params.merge(count: total_count)
    end

    def metadata
      @metadata ||= ApiOnlyPagination::Paginate.new(params[:page], params[:per_page], params[:count])
    end

    def results
      collection
        .limit(metadata.per_page)
        .offset(metadata.offset)
    end

    private

    # count(:all) ignores custom selects; grouped relations return a Hash of group => count
    def total_count
      count = collection.count(:all)
      count.is_a?(Hash) ? count.size : count
    end
  end
end
