require "capybara/rspec"
require "byebug"
require "nacelle"

class TestApp < Rails::Application
  config.secret_key_base = "test"
  config.eager_load = false
  config.logger = Logger.new("/dev/stdout")
  config.hosts = nil

  initializer "log level" do
    Rails.logger.level = Logger::WARN
  end
end

TestApp.initialize!

class ApplicationController < ActionController::Base;end

class TestController < ApplicationController
  def index
    cell = params[:cell] || "test/test"
    render html: %(<cell name="#{cell}"></cell>).html_safe
  end

  def two_cells
    render html: %(<cell name="test/with_greeting"></cell> <cell name="other/with_greeting"></cell>).html_safe
  end

  def leak_test
    cell = TestCell.new_with_controller(self)
    cell.action = :with_greeting
    cell.with_greeting

    fresh_context = view_context
    leaked = fresh_context.respond_to?(:greeting)
    render plain: leaked ? "leaked" : "isolated"
  end
end

class TestCell < Nacelle::Cell
  self.view_path = "spec/views"

  def test options={}
    render
  end

  def with_path_helpers options={}
    render
  end

  def with_greeting
    @greeting = "Hello from TestCell"
    render
  end

  private

  helper_method def greeting
    @greeting
  end
end

class OtherCell < Nacelle::Cell
  self.view_path = "spec/views"

  def with_greeting
    @greeting = "Hello from OtherCell"
    render
  end

  private

  helper_method def greeting
    @greeting
  end
end

TestApp.routes.draw do
  root to: "test#index"
  get "two_cells", to: "test#two_cells"
  get "leak_test", to: "test#leak_test"

  # FIXME Y U NO LOAD ENGINE ROUTES
  namespace :nacelle do
    resources :cells, only: :index
  end
end

feature "nacelle" do
  background do
    Capybara.app = TestApp
  end

  scenario "it replaces <cell> elements with the result of the specified cell invocation" do
    visit "/"
    expect(page.body).to_not include("<cell")
    expect(page.body).to include("TestCell render!")
  end

  scenario "cells can use path helpers" do
    visit "/?cell=test/with_path_helpers"
    expect(page.body).to_not include("<cell")
    expect(page.body).to eq("/nacelle/cells\n")
  end

  scenario "helper methods are scoped to their cell instance, not shared across cells" do
    visit "/two_cells"
    expect(page.body).to include("Hello from TestCell")
    expect(page.body).to include("Hello from OtherCell")
  end

  scenario "helper methods do not leak onto subsequent view contexts" do
    visit "/leak_test"
    expect(page.body).to eq("isolated")
  end

  scenario "it publishes list of cells at /nacelle/cells.json" do
    visit "/nacelle/cells.json"
    expect(JSON.load(page.body)).to eq({ "cells" => [
      { "id" => "other/with_greeting", "name" => "Other With greeting", "form" => nil },
      { "id" => "test/test", "name" => "Test Test", "form" => nil },
      { "id" => "test/with_greeting", "name" => "Test With greeting", "form" => nil },
      { "id" => "test/with_path_helpers", "name" => "Test With path helpers", "form" => nil },
    ] })
  end
end

