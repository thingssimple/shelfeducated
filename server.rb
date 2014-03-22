require 'sinatra'
require 'sinatra/activerecord'
require 'slim'

set :database, "sqlite3:///shelfeducated.db"

require './models/book'
require './models/chapter'
require './models/conclusion'

get '/' do
  slim :index, :locals => {:books => Book.all}
end

post '/books' do
  book = Book.create :name => params[:name], :slug => slugify(params[:name])
  redirect to "/books/#{book.slug}"
end

get '/books/:book_slug' do
  book = Book.find_by_slug params[:book_slug]
  chapters = Chapter.where :book_id => book.id
  slim :book, :locals => {:book => book, :chapters => chapters}
end

post '/books/:book_slug/chapters' do
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
  book = Book.find_by_slug params[:book_slug]
  chapter = Chapter.find_by_slug params[:chapter_slug]
  slim :chapter, :locals => {:book => book, :chapter => chapter}
end

post '/books/:book_slug/conclusion' do
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
  book = Book.find_by_slug params[:book_slug]
  conclusion = Conclusion.find_by_book_id book.id
  slim :conclusion, :locals => {:book => book, :conclusion => conclusion}
end

def slugify value
  value.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end
