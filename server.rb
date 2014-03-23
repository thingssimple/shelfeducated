require 'bcrypt'
require 'sinatra'
require 'sinatra/activerecord'
require 'slim'

set :database, "sqlite3:///shelfeducated.db"

require './models/book'
require './models/chapter'
require './models/conclusion'
require './models/user'

configure do
  enable :sessions
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
end

#
# books
#

get '/' do
  if session.has_key? :user_id
    slim :dashboard, :locals => {:books => Book.all}
  else
    slim :index
  end
end

post '/books' do
  signin_required

  book = Book.create :name => params[:name], :slug => slugify(params[:name])
  redirect to "/books/#{book.slug}"
end

get '/books/:book_slug' do
  signin_required

  book = Book.find_by_slug params[:book_slug]
  chapters = Chapter.where :book_id => book.id
  conclusion = Conclusion.find_by_book_id book.id
  slim :book, :locals => {:book => book, :chapters => chapters, :conclusion => conclusion}
end

post '/books/:book_slug/chapters' do
  signin_required

  book = Book.find_by_slug params[:book_slug]
  chapter = Chapter.create({
    :book_id => book.id,
    :name => params[:chapter],
    :slug => slugify(params[:chapter]),
    :question1 => params[:question1],
    :question2 => params[:question2],
    :question3 => params[:question3],
    :question4 => params[:question4]
  })
  redirect to "/books/#{book.slug}/chapters/#{chapter.slug}"
end

get '/books/:book_slug/chapters/:chapter_slug' do
  signin_required

  book = Book.find_by_slug params[:book_slug]
  chapter = Chapter.find_by_slug params[:chapter_slug]
  slim :chapter, :locals => {:book => book, :chapter => chapter}
end

post '/books/:book_slug/conclusion' do
  signin_required

  book = Book.find_by_slug params[:book_slug]
  chapter = Conclusion.create({
    :book_id => book.id,
    :question1 => params[:question1],
    :question2 => params[:question2],
    :question3 => params[:question3],
    :question4 => params[:question4]
  })
  redirect to "/books/#{book.slug}/conclusion"
end

get '/books/:book_slug/conclusion' do
  signin_required

  book = Book.find_by_slug params[:book_slug]
  conclusion = Conclusion.find_by_book_id book.id
  slim :conclusion, :locals => {:book => book, :conclusion => conclusion}
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

def slugify value
  value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end
