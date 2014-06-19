get '/users/new' do
  @user = User.new
  erb :"users/new"
end

post '/users' do
  @user = User.new(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
  if @user.save
    session[:user_id] = @user.id
    redirect to('/')
  else
    flash.now[:errors] = @user.errors.full_messages
    erb :"users/new"
  end
end

get '/users/reset_password' do
  erb :"users/reset_password"
end

get '/users/reset_password/:token' do
  user = User.first(:password_token => params[:token])

  if user.password_token_timestamp + (60*60) > DateTime.now
    @token = params[:token]
    redirect to ('/users/set_password')
  else
    flash.now[:notice] = "The password token has expired"
    erb :"users/reset_password"
  end
end

get '/users/set_password' do
  erb :"users/set_password"
end

post '/users/new-password/:token' do
  @token = params[:token]
  erb :"users/new-password"
end