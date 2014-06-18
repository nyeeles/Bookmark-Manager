require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'
require './lib/link' # this needs to be done after datamapper is initialised
require './lib/tag'
require './lib/user'
require_relative '../helpers/application'
require_relative '../data_mapper_setup'
set :views, Proc.new { File.join(root,'..','views') }

enable :sessions
set :session_secret, 'super secret'
register Sinatra::Flash

get '/' do
	@links = Link.all
	erb :index
end

post '/links' do
	url = params["url"]
	title = params["title"]
	tags = params["tags"].split(" ").map do |tag|
	#this will either find this tag or create
	#it if it doesn't exist already
	Tag.first_or_create(:text => tag)
	end
	Link.create(:url => url, :title => title, :tags => tags)
	redirect to('/')
end

get '/tags/:text' do
	tag = Tag.first(:text => params[:text])
	@links = tag ? tag.links : []
	erb :index
end

get '/users/new' do
	@user = User.new
	erb :"users/new"
end


post '/users' do
	# we just initialize the object
	# without saving it. It may be invalid
	@user = User.create(:email => params[:email],
									:password => params[:password],
									:password_confirmation => params[:password_confirmation])
	# Let's try saving it
	# if the model is valid,
	# it will be saved
	if @user.save
		# the user.id will be nil if the user wasn't saved
		# because of password mismatch
		session[:user_id] = @user.id
		redirect to('/')
		# if it's not valid,
		# we'll show the same form again
	else
		flash.now[:errors] = @user.errors.full_messages
		erb :"users/new"
	end
end

get '/sessions/new' do
	erb :"sessions/new"
end

post '/sessions' do
	email, password = params[:email], params[:password]
	user = User.authenticate(email, password)
	if user
		session[:user_id] = user.id
		redirect to('/')
	else
		flash[:errors] = "The email or password is incorrect"
		erb :"sessions/new"
	end
end

delete '/sessions' do
	flash[:notice] = "Good bye!"
	session[:user_id] = nil
	redirect to('/')
end