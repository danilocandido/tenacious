require 'rails_helper'
require 'features/feature_helpers'
include FeatureHelpers

RSpec.feature 'Creating an inventory' do
  let(:org_owner) { FactoryGirl.create(:user, :confirmed) }
  let(:member) { FactoryGirl.create(:user, :confirmed) }
  let(:inventory) { FactoryGirl.build(:inventory) }
  let!(:organization) { FactoryGirl.create(:organization, owner: org_owner, users: [org_owner, member]) }
  let!(:original_inventory_count) { Inventory.count }

  shared_examples 'a failed inventory creation' do
    feature 'with no inputs' do
      before do
        click_button 'Create Inventory'
      end

      feature 'fails' do
        scenario "and doesn't save the inventory to the database" do
          expect(Inventory.count).to eq(original_inventory_count)
        end

        scenario 'and shows a messages saying why the inventory was not created' do
          expect(page).to have_content("Name can't be blank")
        end
      end
    end
  end

  shared_examples 'a successful inventory creation' do |owner_string|
    feature 'with valid inputs' do
      if owner_string == 'organization'
        let(:owner) { organization }
      elsif owner_string == 'org_owner'
        let(:owner) { org_owner }
      end

      before do
        fill_in 'inventory_name', with: inventory.name
        fill_in 'inventory_description', with: inventory.description
        click_button 'Create Inventory'
      end

      feature 'succeeds' do
        let(:created_inventory) { Inventory.last }

        scenario 'and saves the inventory to the database' do
          expect(Inventory.count - original_inventory_count).to eq(1)
        end

        scenario 'and has the same attributes as input into the form' do
          expect(created_inventory.name).to eq(inventory.name)
          expect(created_inventory.description).to eq(inventory.description)
        end

        scenario 'and sets the owner as the owner of the inventory' do
          expect(created_inventory.owner).to eq(owner)
        end

        scenario 'and includes the user as part of he inventory' do
          expect(created_inventory.users).to include(org_owner)
        end

        scenario 'and sets the user_role on the inventory as admin' do
          expect(InventoryUser.where(user_id: org_owner, inventory_id: created_inventory).first.user_role).to eq('admin')
        end

        scenario 'and redirects to the inventory path' do
          if owner_string == 'organization'
            expect(current_path).to eq(organization_inventory_path(owner, created_inventory))
          elsif owner_string == 'org_owner'
            expect(current_path).to eq(user_inventory_path(owner, created_inventory))
          end
        end

        scenario 'and shows a message saying the inventory was created' do
          expect(page).to have_content('Your inventory has been successfully created')
        end
      end
    end
  end

  feature 'as a user through the user route' do
    before do
      login_as(org_owner)
      visit '/'
      click_link 'Dashboard'
      click_link 'Create an Inventory'
    end

    scenario 'shows that the inventory will be created under the user' do
      expect(page).to have_content('Create an Inventory for yourself')
    end

    include_examples 'a successful inventory creation', 'org_owner'

    include_examples 'a failed inventory creation'
  end

  feature 'as the owner of the organization through the organization route' do
    before do
      login_as(org_owner)
      visit '/'
      click_link 'Dashboard'
      click_link organization.name
      click_link 'Create an Inventory'
    end

    scenario 'shows that the inventory will be created under the organization' do
      expect(page).to have_content("Create an Inventory for #{organization.name}")
    end

    scenario 'has a link to the organization' do
      expect(page).to have_link(organization.name, href: organization_path(organization))
    end

    include_examples 'a successful inventory creation', 'organization'

    include_examples 'a failed inventory creation'
  end

  feature 'as a member of the organization' do
    before do
      login_as(member)
      visit new_organization_inventory_path(organization)
    end

    scenario 'will redirect back to the organization path' do
      expect(current_path).to eq(organization_path(organization))
    end

    scenario 'shows a message saying why the member was redirected' do
      expect(page).to have_content('Only the owner of an organization can create an inventory for it')
    end
  end

  feature 'as a guest' do
    before do
      visit new_user_inventory_path(org_owner)
    end

    will_redirect_to_login_page
  end
end
