require 'rack-flash'
require 'date'
require 'i18n'
require 'i18n/backend/fallbacks'
require './sinatra/months'

class ApplicationController < Sinatra::Base
  helpers Sinatra::Months

  configure do
    set :views, 'app/views'
    set :public_dir, 'public'

    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']

    use Rack::Flash, sweep: true

    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join('config/locales', '*.yml')]
    I18n.backend.load_translations
    I18n.available_locales = %i[en ja]
    I18n.default_locale = :en
  end

  before '/:locale/*' do
    I18n.locale = params[:locale]
  end

  get '/:locale/' do
    if logged_in?
      @user = current_user

      redirect to "/#{I18n.locale}/users/#{@user.slug}"
    end

    erb :index
  end

  get '/' do
    redirect to "/#{I18n.default_locale}/"
  end

  helpers do
    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def logged_in?
      !!current_user
    end

    def t(*args)
      I18n.t(*args)
    end

    def l(*args)
      I18n.l(*args)
    end
  end
end
