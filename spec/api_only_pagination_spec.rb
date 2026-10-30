# frozen_string_literal: true

RSpec.describe ApiOnlyPagination do
  it "has a version number" do
    expect(ApiOnlyPagination::VERSION).not_to be nil
  end

  describe ".do_paginate" do
    before do
      5.times { |i| User.create!(name: "user#{i}", role: i.even? ? "admin" : "member") }
    end

    it "returns the requested page with metadata" do
      result = User.order(:id).do_paginate(2, 2)

      expect(result.data.map(&:name)).to eq(%w[user2 user3])
      expect(result.current_page).to eq(2)
      expect(result.per_page).to eq(2)
      expect(result.total_pages).to eq(3)
      expect(result.total_records).to eq(5)
    end

    it "respects scopes chained before it" do
      result = User.where(role: "admin").do_paginate(1, 10)

      expect(result.total_records).to eq(3)
      expect(result.data.map(&:role).uniq).to eq(["admin"])
    end

    it "falls back to defaults for nil, zero and non-numeric input" do
      [[nil, nil], [0, 0], %w[abc xyz]].each do |page, per_page|
        result = User.do_paginate(page, per_page)

        expect(result.current_page).to eq(1)
        expect(result.per_page).to eq(20)
      end
    end

    it "accepts numeric strings from request params" do
      result = User.do_paginate("2", "3")

      expect(result.current_page).to eq(2)
      expect(result.data.size).to eq(2)
    end

    it "falls back to defaults for negative input instead of producing invalid SQL" do
      result = User.do_paginate(-1, -5)

      expect(result.current_page).to eq(1)
      expect(result.per_page).to eq(20)
      expect(result.data.size).to eq(5)
    end

    it "caps per_page at max_per_page" do
      ApiOnlyPagination.configure { |c| c.max_per_page = 3 }

      expect(User.do_paginate(1, 50).per_page).to eq(3)
    end

    it "counts records when the relation has a custom select" do
      result = User.select(:id, :name).do_paginate(1, 2)

      expect(result.total_records).to eq(5)
      expect(result.data.size).to eq(2)
    end

    it "counts groups when the relation is grouped" do
      result = User.select(:role).group(:role).do_paginate(1, 1)

      expect(result.total_records).to eq(2)
      expect(result.total_pages).to eq(2)
      expect(result.data.to_a.size).to eq(1)
    end

    it "returns an empty page past the end" do
      result = User.do_paginate(10, 2)

      expect(result.data).to be_empty
      expect(result.total_pages).to eq(3)
    end
  end

  describe "response format" do
    before do
      5.times { |i| User.create!(name: "user#{i}", role: "member") }
    end

    it "includes next and previous page numbers" do
      expect(User.do_paginate(2, 2)).to have_attributes(next_page: 3, previous_page: 1)
      expect(User.do_paginate(1, 2)).to have_attributes(next_page: 2, previous_page: nil)
      expect(User.do_paginate(3, 2)).to have_attributes(next_page: nil, previous_page: 2)
    end

    it "serializes to a stable JSON shape" do
      json = User.order(:id).do_paginate(2, 2).as_json

      expect(json.keys).to eq(%w[data per_page current_page total_pages total_records next_page previous_page])
      expect(json["data"].map { |user| user["name"] }).to eq(%w[user2 user3])
      expect(json).to include("per_page" => 2, "current_page" => 2, "total_pages" => 3,
                              "total_records" => 5, "next_page" => 3, "previous_page" => 1)
    end

    it "applies serializer options to the records, not the envelope" do
      json = User.order(:id).do_paginate(1, 1).as_json(only: :name)

      expect(json["data"]).to eq([{ "name" => "user0" }])
      expect(json["total_records"]).to eq(5)
    end

    it "renders through to_json" do
      parsed = JSON.parse(User.do_paginate(1, 2).to_json)

      expect(parsed["next_page"]).to eq(2)
      expect(parsed["data"].size).to eq(2)
    end

    it "exposes a symbol-keyed hash" do
      expect(User.do_paginate(1, 2).to_h).to include(current_page: 1, next_page: 2, previous_page: nil)
    end

    it "keeps do_paginate and paginated_response but no longer defines paginate" do
      expect(User).to respond_to(:do_paginate, :paginated_response)
      expect(User).not_to respond_to(:paginate)
    end
  end

  describe ApiOnlyPagination::Paginate do
    it "treats an empty collection's first page as both first and last" do
      meta = described_class.new(1, 10, 0)

      expect(meta.total_pages).to eq(0)
      expect(meta).to be_first_page
      expect(meta).to be_last_page
      expect(meta.next_page).to be_nil
    end

    it "treats pages past the end as last with no next page" do
      meta = described_class.new(5, 10, 15)

      expect(meta).to be_last_page
      expect(meta.next_page?).to be false
      expect(meta.next_page).to be_nil
    end
  end
end
