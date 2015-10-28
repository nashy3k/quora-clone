enable :sessions

get '/' do
	@users = User.all
  	erb :"static/index"
end

get '/users/:id/edit' do
	@user = User.find(session[:user_id])
		erb :"static/profile"
end

get '/static/main' do
	@user = User.find(session[:user_id])
		erb :"static/main"
end

post '/signup' do
	#create a new User
	@user = User.new(email: params[:user][:email], password: params[:user][:password])
	if @user.save
		# @message = "Signed up. You may login"
		session[:user_id] = @user.id
		session[:user_name] = @user.username
		redirect to '/users/:id/edit'
		# return @url.to_json        
	else
		@users = User.all
		redirect to '/'
	end
end

post '/profile' do
	#update a User profile
	@user = User.find(session[:user_id])
	@user.update_attributes(username: params[:user][:username], first_name: params[:user][:first_name], last_name: params[:user][:last_name], email: params[:user][:email], password: params[:user][:password])
	if @user
		redirect to '/static/main'
		# return @url.to_json
	else
		redirect to '/users/:id/edit'
	end	
end

post '/login' do
# apply your authentication method to check if a user has entered a valid email and password
# if a user has successfully been authenticated, you can assign the current user id to a session
	if @user = User.authenticate(params[:user][:email], params[:user][:password])
	session[:user_id] = @user.id
	session[:user_name] = @user.username	
	redirect to '/static/main'
	else
		redirect to '/'
	end
end

get '/logout' do
# kill a session when a user choses to logout, for example assign nil to a session
# redirect to the appropriate page
	session.delete(:user_id)
	redirect to '/'
end