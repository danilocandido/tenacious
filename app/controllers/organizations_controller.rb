class OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.owner = current_user
    @organization.users << current_user
    if @organization.save
      flash[:success] = 'Your organization has been successfully created'
      redirect_to organization_path(@organization)
    else
      render 'new'
    end
  end

  def show
    @organization = Organization.find(params[:id])
    return if @organization.users.include? current_user
    flash[:alert] = 'You need to be part of this organization to view it'
    redirect_to root_path
  end

  private

  def organization_params
    params.require(:organization).permit(:name)
  end
end
