enable :sessions

get '/' do
	session.delete(:user_id)
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
		redirect to '/questions'
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
	redirect to '/questions'
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

get '/questions/new' do
	@questions = Question.all
  	erb :"static/main"
end

post '/questions' do
	question = current_user.questions.new(params[:question])
	if question.save
		# @message = "Question asked"
	
		redirect to "/questions/#{question.id}/edit"
		# return @url.to_json        
	else
		@questions = Question.all
		redirect to '/questions'
	end

end

get '/questions' do
	@questions = Question.all
	# @question_users = Question.joins(:user).all
	# question_users = Question.joins(:user).where(users: {username: session{:user_name})
  	erb :"static/main"
end

get '/questions/:id' do
	@question = Question.find(params[:id])
  	erb :"static/question"
end

get '/user/:id/questions/' do
	@questions = Question.where(user_id: params[:id])
  	erb :"static/user_questions"

end

get '/user/:id/answers/' do
	@questions = Question.where(user_id: params[:id])
	@answers = Answer.where(user_id: params[:id])
  	erb :"static/user_answers"	
end

get '/questions/:id/edit' do
	# @question_users = User.joins(:questions).all
	@question = Question.find(params[:id])
	if session[:user_id] == @question.user_id
  	erb :"static/question_edit"
  else
  	erb :"static/not_allowed"	
  end	
end

post '/questions/:id/edit' do
	#update a Question
	@question = Question.find(params[:id])
	@question.update_attributes(title: params[:question][:title], description: params[:question][:description])
	if @question
		redirect to '/questions'
		# return @url.to_json
	else
		redirect to '/questions/:id/edit'
	end	
end

delete '/questions/:id' do
	question = Question.find(params[:id])
if session[:user_id] == question.user_id
	question.destroy
	redirect to '/questions'	
	else
  	erb :"static/not_allowed"	
  end
end

#--------------------------Answers-------------
 
get "/questions/:q_id/answers/new" do
	@question = Question.find(params[:q_id])
	@answers = Answer.find_by(question_id: params[:q_id])
  	erb :"static/submit_answer"
end

post "/questions/:q_id/answers" do
	answer = current_user.answers.new(params[:answers].merge({question_id: params[:q_id]}))
	if answer.save
		# @message = "Question asked"
		redirect to "/questions/#{params[:q_id]}/answers"
		# return @url.to_json        
	else
		redirect to "/questions/#{params[:q_id]}/answers/new"
	end
end

get "/questions/:q_id/answers" do
	@question = Question.find(params[:q_id])
	@answers = Answer.where(question_id: params[:q_id])
  	erb :"static/all_answers"	
end

get '/questions/:q_id/answers/:a_id/' do
	@question = Question.find(params[:q_id])
	@answer = Answer.find(params[:a_id])
  	erb :"static/answer"	
end

get '/questions/:q_id/answers/:a_id/edit' do
	@question = Question.find(params[:q_id])	
	@answer = Answer.find(params[:a_id])
	if session[:user_id] == @answer.user_id		
  	erb :"static/answer_edit"	
  else
  	erb :"static/not_allowed"	
  end	
end

post '/questions/:q_id/answers/:a_id/edit' do
	#update an Answer
	@question = Question.find(params[:q_id])
	@answer = Answer.find(params[:a_id])
	@answer.update_attributes(title: params[:answer][:title], description: params[:answer][:description])
	if @answer
		redirect to "/questions/#{params[:q_id]}/answers"
		# return @url.to_json
	else
		redirect to "/questions/"#{params[:q_id]}/answers/#{params[:a_id]/edit
	end	
end

delete '/questions/:q_id/answers/:a_id' do
	answer = Answer.find(params[:a_id])
	if session[:user_id] == answer.user_id		
	answer.destroy
	redirect to "/questions/#{params[:q_id]}/answers"	
	else
  	erb :"static/not_allowed"	
  end	
end

delete '/questions/:q_id/answers' do
	question = Question.find(params[:q_id])
	if session[:user_id] == question.user_id		
	question.answers.destroy_all 
	redirect to "/questions/#{params[:q_id]}/answers"	
	else
  	erb :"static/not_allowed"	
  end	
end