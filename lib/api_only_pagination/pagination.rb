# frozen_string_literal: true

module ApiOnlyPagination
  class Pagination
    attr_reader :collection, :params

    def initialize(collection, params = {})
      @collection = collection
      @params = params.merge(count: collection.count)
    end

    def metadata
      @metadata ||= ApiOnlyPagination::Paginate.new(params[:page], params[:per_page], params[:count])
    end

    def results
      collection
        .limit(metadata.per_page)
        .offset(metadata.offset)
    end
  end
end
