require "capybara/rspec"
require "byebug"
require "nacelle"

class TestApp < Rails::Application
  config.secret_key_base = "test"
  config.middleware.use Nacelle::Middleware
end

Rails.logger = Logger.new("/dev/null")

class TestController < ActionController::Base
  def index
    render html: '<cell name="test/test"></cell>'.html_safe
  end
end

class TestCell < Cell::Base
  def test
    "TestCell render!"
  end
end

TestApp.routes.draw do
  root to: "test#index"
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
end
