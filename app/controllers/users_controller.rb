class UsersController < ApplicationController
    def new
      @user = User.new
      @role = params[:role]
    end

    def edit
      @user  = User.find(params[:id])
      @role = @user.role
    end

    def create
      @user = User.new(user_params)
      @user.email = @user.email.downcase.presence
      # seeker_params = params[:seeker] if params[:seeker]
      @user.logged_in = true
      @user.last_seen = Time.now
      @user.username = @user.username.downcase

      if @user.save
        session[:user_id] = @user.id  unless current_user && current_user.role == "Admin" # auto log in 
        if current_user.role == "Seeker"
        	redirect_to new_seeker_path, notice: "Welcome aboard, #{@user.firstName}!"
        elsif current_user.role == "Employer"
        	redirect_to new_employer_path, notice: "Welcome aboard, #{@user.firstName}!"
        elsif current_user.role == "Admin"
          
          redirect_to admin_users_path, notice: "User #{@user.firstName} successfully!"
        else
          # flash[:error] = @user.errors.full_messages.to_sentence
          flash[:error] = @user.errors.full_messages.to_sentence
          render :new, notice: "User could not be created!"
        end
      else
        @role = params[:role]
        flash[:error] = @user.errors.full_messages.to_sentence
        render :new, notice: "User could not be created!"
      end
    end
    def update
      @user  = User.find(params[:id])
      @role = @user.role
      @user.username = @user.username.downcase
      @user.email = @user.email.downcase.presence
      unless @user.role == "Landing"
        if @user.update_attributes(user_params) && current_user.role == "Seeker"
          @seeker = Seeker.where(user_id: @user.id).first
          redirect_to seeker_path(@seeker), notice: "Updated successfully!"
        elsif @user.update_attributes(user_params) && current_user.role == "Employer"
          @employer = Employer.where(user_id: @user.id).first
          redirect_to employer_path(@employer), notice: "Updated successfully!"
        elsif @user.update_attributes(user_params) && current_user.role == "Admin"
          redirect_to admin_users_path, notice: "Updated successfully!"
        else
          # flash[:error] = @user.errors.full_messages.to_sentence
          # flash[:error] = "Role didn't work"
          logger.info "$$$$$$$$$$$$$$$$  #{@user.errors.full_messages.to_sentence} $$$$$$$$$$$$$$$$$$$$$$$"
          flash[:error] = "User could not be updated!"
          redirect_back(fallback_location: root_path)
        end
      else
        @user.temp = false
        @user.logged_in = true
        @user.last_seen = Time.now
        if @user.update_attributes(user_params)
          @seeker = Seeker.where(user_id: @user.id).first
          @seeker.temp = false
          @seeker.save
          @user.role = "Seeker"
          @user.logged_in = true
          @user.last_seen = Time.now
          @user.save
          if @user.save
            session[:user_id] = @user.id  unless current_user && current_user.role == "Admin" # auto log in 
          end
          redirect_to seeker_path(@seeker), notice: "Updated successfully!"
          # redirect_to edit_landing_seeker_path(@seeker), seeker_id: @seeker.id , notice: "Updated successfully!"
        else
          # flash[:error] = @user.errors.full_messages.to_sentence
          logger.info "$$$$$$$$$$$$$$$$  #{@user.errors.full_messages.to_sentence} $$$$$$$$$$$$$$$$$$$$$$$"
          flash[:error] = "User could not be created!"
          # flash[:error] =  "#{@user.errors.full_messages.to_sentence}"
          render :edit
        end
      end
    end
 

  protected

  def user_params
    params.require(:user).permit(:username, :landing, :temp, :seeker, :email, :firstName, :lastName, :password, :password_confirmation, :role, :phoneNo)
  end
end