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
end

class TestCell < Nacelle::Cell
  self.view_path = "spec/views"

  def test options={}
    render
  end

  def with_path_helpers options={}
    render
  end
end

TestApp.routes.draw do
  root to: "test#index"

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

  scenario "it publishes list of cells at /nacelle/cells.json" do
    visit "/nacelle/cells.json"
    expect(JSON.load(page.body)).to eq({ "cells" => [
      { "id" => "test/test", "name" => "Test Test", "form" => nil },
      { "id" => "test/with_path_helpers", "name" => "Test With path helpers", "form" => nil },
    ] })
  end
end

