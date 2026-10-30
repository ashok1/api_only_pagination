# frozen_string_literal: true

module ApiOnlyPagination
  # Global settings, changed through ApiOnlyPagination.configure
  class Configuration
    attr_accessor :default_page_size, :max_per_page, :default_page

    def initialize
      @default_page_size = 20
      @max_per_page = 100
      @default_page = 1
    end
  end
end
