class InventoryUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_inventory, except: [:confirm_invitation]
  before_action :load_pending_inventory, only: [:confirm_invitation]

  def new
    unless current_user.inventory_access?('admin', @inventory)
      flash[:alert] = 'You must be an administrator of this inventory to view this page'
      redirect_to [@inventory.owner, @inventory]
    end
    @users = User.search(params[:query])
    @inventory_user = InventoryUser.new
  end

  def create
    @inventory_user = InventoryUser.new(inventory_user_params)
    @inventory_user.user_id = params[:user_id]
    @inventory_user.inventory_id = @inventory.id
    @inventory_user.save
    flash[:success] = "#{@inventory_user.user.username} has been invited to this inventory"
    redirect_to [@inventory.owner, @inventory]
  end

  def confirm_invitation
    inventory_user = InventoryUser.where(user_id: current_user, inventory_id: @inventory).first
    inventory_user.confirmed_at = Time.now
    inventory_user.save
    flash[:success] = 'You have successfully joined this inventory'
    redirect_to [@inventory.owner, @inventory]
  end

  private

  def load_inventory
    @inventory = current_user.inventories.find(params[:inventory_id])
  end

  def load_pending_inventory
    @inventory = current_user.pending_inventories.find(params[:inventory_id])
  end

  def inventory_user_params
    params.require(:inventory_user).permit(:user_role)
  end
end
