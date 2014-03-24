require 'bcrypt'
require 'rack/csrf'
require 'sinatra'
require 'sinatra/activerecord'
require 'slim'

set :database, "sqlite3:///shelfeducated.db"

require './models/book'
require './models/chapter'
require './models/conclusion'
require './models/user'

configure do
  use Rack::Session::Cookie, :secret => "this is a long string that really needs to be better"
  use Rack::Csrf
end

helpers do
  def signed_in?
    not session[:user_id].nil?
  end

  def signin_required
    if not signed_in?
      redirect to '/signin'
    end
  end

  def owner_of_book_required(book)
    if session[:user_id] != book.user_id
      redirect to '/'
    end
  end
end

#
# users
#

get '/signup' do
  slim :signup
end

post '/signup' do
  if params[:password] == params[:confirm_password]
    salt = BCrypt::Engine.generate_salt
    hash = BCrypt::Engine.hash_secret params[:password], salt
    user = User.create({
      :email => params[:email],
      :password => hash,
      :password_salt => salt
    })
    session[:user_id] = user.id
    redirect to '/'
  else
    slim :signup, :locals => {:params => params}
  end
end

get '/signin' do
  slim :signin
end

post '/signin' do
  user = User.find_by_email params[:email]
  if user.password == BCrypt::Engine.hash_secret(params[:password], user.password_salt)
    session[:user_id] = user.id
    redirect to '/'
  else
    slim :signin, :locals => {:params => params}
  end
end

get '/signout' do
  signin_required

  session.delete :user_id
  redirect to '/'
end

#
# books
#

get '/' do
  if session.has_key? :user_id
    user_id = session[:user_id]
    slim :dashboard, :locals => {:books => Book.where(:user_id => user_id), :user_id => user_id}
  else
    slim :index
  end
end

post '/:user_id' do
  signin_required
  book = Book.create({
    :user_id => session[:user_id].to_i,
    :name => params[:name],
    :slug => slugify(params[:name])
  })

  redirect to "/#{book.user_id}/#{book.slug}"
end

get '/:user_id/:book_slug' do
  signin_required
  book = Book.find_by_slug_and_user_id params[:book_slug], params[:user_id]
  owner_of_book_required book

  chapters = Chapter.where :book_id => book.id
  conclusion = Conclusion.find_by_book_id book.id
  slim :book, :locals => {:book => book, :chapters => chapters, :conclusion => conclusion}
end

post '/:user_id/:book_slug/chapters' do
  signin_required
  book = Book.find_by_slug_and_user_id params[:book_slug], session[:user_id]
  owner_of_book_required book

  chapter = Chapter.create({
    :book_id => book.id,
    :name => params[:chapter],
    :slug => slugify(params[:chapter]),
    :question1 => params[:question1],
    :question2 => params[:question2],
    :question3 => params[:question3],
    :question4 => params[:question4]
  })
  redirect to "/#{book.user_id}/#{book.slug}/chapters/#{chapter.slug}"
end

get '/:user_id/:book_slug/chapters/:chapter_slug' do
  signin_required
  book = Book.find_by_slug_and_user_id params[:book_slug], session[:user_id]
  owner_of_book_required book

  chapter = Chapter.find_by_slug_and_book_id params[:chapter_slug], book.id
  slim :chapter, :locals => {:book => book, :chapter => chapter}
end

post '/:user_id/:book_slug/conclusion' do
  signin_required
  book = Book.find_by_slug_and_user_id params[:book_slug], session[:user_id]
  owner_of_book_required book

  chapter = Conclusion.create({
    :book_id => book.id,
    :question1 => params[:question1],
    :question2 => params[:question2],
    :question3 => params[:question3],
    :question4 => params[:question4]
  })
  redirect to "/#{book.user_id}/#{book.slug}/conclusion"
end

get '/:user_id/:book_slug/conclusion' do
  signin_required
  book = Book.find_by_slug_and_user_id params[:book_slug], session[:user_id]
  owner_of_book_required book

  conclusion = Conclusion.find_by_book_id book.id
  slim :conclusion, :locals => {:book => book, :conclusion => conclusion}
end

def slugify value
  value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end
