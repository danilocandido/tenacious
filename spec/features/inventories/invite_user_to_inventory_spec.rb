require 'rails_helper'
require 'features/feature_helpers'
include FeatureHelpers

RSpec.feature 'Inviting a user to an inventory' do
  let(:user_to_invite) { FactoryGirl.create(:user, :confirmed) }
  let(:user) { FactoryGirl.create(:user, :confirmed) }
  let(:inventory) { FactoryGirl.create(:inventory, owner: user) }

  shared_examples 'a successful invitation and acception' do |user_role|
    before do
      select(user_role, from: 'inventory_user_user_role')
      click_button 'Invite User'
    end

    scenario 'creates an unconfirmed relationship between the invited user and the inventory' do
      expect(user_to_invite.inventory_access?(user_role, inventory)).to eq(nil)
    end

    scenario 'shows a message saying the user has been invited to the inventory' do
      expect(page).to have_content("#{user_to_invite.username} has been invited to this inventory")
    end

    feature 'then accepting the invite' do
      before do
        click_button 'Sign Out'
        login_as(user_to_invite)
        visit '/'
        click_link 'Dashboard'
        click_button 'accept invitation'
      end

      scenario 'confirms the relationship between the invited user and the inventory' do
        expect(user_to_invite.inventory_access?(user_role, inventory)).to eq(true)
      end

      scenario 'shows a message saying the user has successfully joined the inventory' do
        expect(page).to have_content('You have successfully joined this inventory')
      end
    end
  end

  feature 'as an administrator of the inventory' do
    before do
      FactoryGirl.create(:inventory_user, :confirmed, user: user, inventory: inventory, user_role: 'admin')
      login_as(user)
      visit '/'
      click_link 'Dashboard'
      click_link inventory.name
      fill_in 'query', with: user_to_invite.username
      click_button 'Search'
    end

    feature 'with read access' do
      include_examples 'a successful invitation and acception', 'read'
    end

    feature 'with write access' do
      include_examples 'a successful invitation and acception', 'write'
    end

    feature 'with admin access' do
      include_examples 'a successful invitation and acception', 'admin'
    end
  end

  feature 'as a member of the inventory' do
    before do
      FactoryGirl.create(:inventory_user, :confirmed, user: user, inventory: inventory)
      login_as(user)
      visit new_inventory_user_path(inventory)
    end

    scenario 'will redirect back to the inventory path' do
      expect(current_path).to eq(user_inventory_path(user, inventory))
    end

    scenario 'shows a message saying why the member was redirected' do
      expect(page).to have_content('You must be an administrator of this inventory to view this page')
    end
  end

  feature 'as a logged in user' do
    scenario 'responds with RecordNotFound' do
      login_as(user)
      expect { visit new_inventory_user_path(inventory) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  feature 'as a guest' do
    before do
      visit new_inventory_user_path(inventory)
    end

    will_redirect_to_login_page
  end
end
