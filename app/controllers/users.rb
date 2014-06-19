get '/users/new' do
  # note the view is in views/users/new.erb
  # we need the quotes because otherwise
  # ruby would divide the symbol :users by the
  # variable new (which makes no sense)
  @user = User.new
  erb :"users/new"
end

post '/users' do
  # we just initialize the object
  # without saving it. It may be invalid
  @user = User.new(:email => params[:email], 
              :password => params[:password],
              :password_confirmation => params[:password_confirmation])  
  # let's try saving it
  # if the model is valid,
  # it will be saved
  if @user.save
    session[:user_id] = @user.id
    redirect to('/')
    # if it's not valid,
    # we'll show the same
    # form again
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
    redirect to ('/users/set_password')
  else
    flash.now[:notice] = "The password token has expired"
    erb :"users/reset_password"
  end
end

get '/users/set_password' do
  erb :"users/set_password"
end


# get '/users/set_password/:token' do
#   user = User.first(:password_token => params[:token])

#   if user.password_token_timestamp + (60+60) > DateTime.now
#     redirect to ('/users/set_password')
#   else
#     flash.now[:notice] = "The password token has expired"
#     erb :"users/reset_password"
#   end
# end