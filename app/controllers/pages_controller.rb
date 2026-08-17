class PagesController < ApplicationController
  # Only allow modern browsers on regular HTML pages.
  allow_browser versions: :modern

  def home
  end

  def how_to
  end

  def updates
  end
end
