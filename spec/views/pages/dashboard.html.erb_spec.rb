require 'rails_helper'

RSpec.describe 'pages/dashboard', type: :view do
  let(:owner) { FactoryGirl.build_stubbed(:user) }
  let(:organizations) { FactoryGirl.build_stubbed_list(:organization, 2) }
  let(:organization_owner) { organizations.first }
  let(:organization_inventories) { FactoryGirl.build_stubbed_list(:inventory, 2, owner: organization_owner) }
  let(:user_inventories) { FactoryGirl.build_stubbed_list(:inventory, 2, owner: owner) }
  let(:pending_inventories) { FactoryGirl.build_stubbed_list(:inventory, 2, owner: owner) }
  let(:user) do
    FactoryGirl.build_stubbed(:user, inventories: user_inventories + organization_inventories,
                                     pending_inventories: pending_inventories,
                                     organizations: organizations)
  end

  before do
    allow(view).to receive(:current_user).and_return(user)
    render
  end

  it 'has links to the organizations the user belongs to' do
    organizations.each do |organization|
      expect(rendered).to have_link(organization.name, href: organization_path(organization))
    end
  end

  it 'has links to the inventories the user belongs to owned by an organization' do
    organization_inventories.each do |inventory|
      expect(rendered).to have_link("#{organization_owner.name} / #{inventory.name}",
                                    href: organization_inventory_path(organization_owner, inventory))
    end
  end

  it 'has links to inventories the user belongs to owned by a user' do
    user_inventories.each do |inventory|
      expect(rendered).to have_link(inventory.name, href: user_inventory_path(owner, inventory))
    end
  end

  it 'has links to inventories the user has been invited to with a button to accept the invitation' do
    pending_inventories.each do |inventory|
      expect(rendered).to have_link(inventory.name, href: user_inventory_path(owner, inventory))
    end
    expect(rendered).to have_xpath("//input[@value = 'accept invitation']", count: 2)
  end

  it 'has a link to create an organization' do
    expect(rendered).to have_link('Create an Organization', href: new_organization_path)
  end

  it 'has a link to create an inventory' do
    expect(rendered).to have_link('Create an Inventory', href: new_user_inventory_path(user))
  end
end
