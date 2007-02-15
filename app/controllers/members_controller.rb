class MembersController < ApplicationController
  permit "site_admin or admin of :current_basket"

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @non_member_roles_plural = Hash.new
    @members = nil
    @current_basket.accepted_roles.each do |role|
      role_plural = role.name.pluralize
      instance_variable_set("@#{role_plural}", @current_basket.send("has_#{role_plural}"))
      if role_plural == 'members'
        @members = @current_basket.has_members
        @members_pages = Paginator.new self, @members.size, 10, params[:page]
      else
        @non_member_roles_plural[role.name] = role_plural
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def change_membership_type
    membership_type = params[:role]
    old_membership_type = params[:old_role]
    can_change = true
    if old_membership_type == 'site_admin' # to pick up the chance we are changing  from site admin to something else
      can_change = need_one_site_admin?
    end

    if can_change == true
      @user = User.find(params[:id])
      # bit to do the change
      @current_basket.accepted_roles.each do |role|
        @user.has_no_role(role.name,@current_basket)
      end
      @user.has_role(membership_type,@current_basket)
      flash[:notice] = 'User successfully changed role.'
      redirect_to :action => 'list'
    else
      flash[:notice] = "Unable to have no site administrators"
      redirect_to :action => 'list'
    end
  end

  def need_one_site_admin?
    if @current_basket.has_site_admins.size >= 2 #currently only one site_admin so cant remove it
      return true
    else
      return false
    end
  end

end