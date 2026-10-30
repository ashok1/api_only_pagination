# frozen_string_literal: true

require "action_controller"

class UsersController < ActionController::API
  def index
    render_paginated User.order(:id)
  end

  def names
    render_paginated User.order(:id), only: [:name], status: :partial_content
  end

  def explicit
    render_paginated User.order(:id), page: 2, per_page: 1
  end

  def with_headers
    render_paginated User.order(:id), pagination_headers: true
  end
end

RSpec.describe ApiOnlyPagination::Controller do
  def get(action, query = "")
    env = Rack::MockRequest.env_for("http://example.org/users?#{query}")
    status, headers, body = UsersController.action(action).call(env)
    payload = +""
    body.each { |chunk| payload << chunk }

    [status, headers.to_h.transform_keys(&:downcase), JSON.parse(payload)]
  end

  before do
    5.times { |i| User.create!(name: "user#{i}", role: "member") }
  end

  it "paginates using page and per_page from the query string" do
    status, _headers, json = get(:index, "page=2&per_page=2")

    expect(status).to eq(200)
    expect(json["data"].map { |user| user["name"] }).to eq(%w[user2 user3])
    expect(json).to include("current_page" => 2, "per_page" => 2, "total_records" => 5, "next_page" => 3)
  end

  it "falls back to the configured defaults without params" do
    _status, _headers, json = get(:index)

    expect(json).to include("current_page" => 1, "per_page" => 20)
  end

  it "passes render options through, applying serializer options to the records" do
    status, _headers, json = get(:names, "per_page=1")

    expect(status).to eq(206)
    expect(json["data"]).to eq([{ "name" => "user0" }])
  end

  it "lets explicit page and per_page override params" do
    _status, _headers, json = get(:explicit, "page=5&per_page=5")

    expect(json).to include("current_page" => 2, "per_page" => 1)
  end

  it "does not add pagination headers unless asked" do
    _status, headers, _json = get(:index)

    expect(headers.keys).not_to include("x-total-count", "link")
  end

  it "adds pagination headers when asked" do
    _status, headers, _json = get(:with_headers, "page=2&per_page=2&q=abc")

    expect(headers).to include("x-total-count" => "5", "x-total-pages" => "3", "x-per-page" => "2", "x-page" => "2")
    expect(headers["link"].split(", ")).to eq([
                                                '<http://example.org/users?page=1&per_page=2&q=abc>; rel="first"',
                                                '<http://example.org/users?page=1&per_page=2&q=abc>; rel="prev"',
                                                '<http://example.org/users?page=3&per_page=2&q=abc>; rel="next"',
                                                '<http://example.org/users?page=3&per_page=2&q=abc>; rel="last"'
                                              ])
  end

  it "adds pagination headers for every call when configured globally" do
    ApiOnlyPagination.configure { |config| config.pagination_headers = true }

    _status, headers, _json = get(:index, "per_page=5")

    expect(headers["x-total-count"]).to eq("5")
    expect(headers["link"]).to eq('<http://example.org/users?page=1&per_page=5>; rel="first", ' \
                                  '<http://example.org/users?page=1&per_page=5>; rel="last"')
  end

  it "omits the Link header when there are no pages" do
    User.delete_all

    _status, headers, json = get(:with_headers)

    expect(json["data"]).to eq([])
    expect(headers["x-total-count"]).to eq("0")
    expect(headers.keys).not_to include("link")
  end

  it "is available to ActionController::Base too" do
    expect(ActionController::Base.private_method_defined?(:render_paginated)).to be true
  end

  it "never becomes a routable action" do
    expect(UsersController.action_methods).not_to include("render_paginated")
  end
end
