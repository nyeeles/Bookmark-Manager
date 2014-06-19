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
    flash[:errors] = ["The email or password are incorrect"]
    erb :"sessions/new"
  end
end

delete '/sessions' do
  flash[:notice] = "Good bye!"
  session[:user_id] = nil
  redirect to('/')
end

post '/sessions/new' do
  flash[:notice] = "Please check your email for a new password"
  email = params[:email]
  user = User.first(:email => email)
  user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
  user.password_token_timestamp = Time.now
  user.save
  redirect to('/sessions/new')
end
