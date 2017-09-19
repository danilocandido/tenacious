class InventoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_owner
  before_action :set_inventory, only: [:edit, :update, :show]
  before_action :validate_organization_owner, only: [:new, :create, :edit, :update]

  def new
    @inventory = Inventory.new
  end

  def edit
  end

  def create
    @inventory = Inventory.new(inventory_params)
    @inventory.owner = @owner
    if @inventory.save
      inventory_user = InventoryUser.new(user: current_user, inventory: @inventory, user_role: 'admin')
      inventory_user.save
      flash[:success] = 'Your inventory has been successfully created'
      redirect_to [@owner, @inventory]
    else
      render 'new'
    end
  end

  def update
    if @inventory.update(inventory_params)
      flash[:success] = 'Your inventory has been successfully edited'
      redirect_to [@owner, @inventory]
    else
      render 'edit'
    end
  end

  def show
    unless @inventory.users.include? current_user
      flash[:alert] = 'You need to be part of this inventory to view it'
      redirect_to root_path and return
    end
  end

  private

  def inventory_params
    params.require(:inventory).permit(:name, :description)
  end

  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  def set_owner
    resource, id = request.path.split('/')[1, 2]
    @owner = resource.singularize.classify.constantize.find(id)
  end

  def validate_organization_owner
    return unless @owner.class == Organization && @owner.owner != current_user
    flash[:alert] = 'Only the owner of an organization can create an inventory for it'
    redirect_to organization_path(@owner)
  end
end
