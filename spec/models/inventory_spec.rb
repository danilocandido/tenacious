require 'rails_helper'

RSpec.describe Inventory, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:inventory)).to be_valid
  end

  describe '#name' do
    it 'is valid when under 256 characters' do
      expect(FactoryGirl.build(:inventory, name: Faker::Lorem.characters(255))).to be_valid
    end

    it 'is invalid when nil' do
      expect(FactoryGirl.build(:inventory, name: nil)).not_to be_valid
    end

    it 'is invalid when over 255 characters' do
      expect(FactoryGirl.build(:inventory, name: Faker::Lorem.characters(256))).not_to be_valid
    end

    describe 'uniqueness' do
      before do
        FactoryGirl.create(:inventory, name: 'duplicate')
      end

      it 'is invalid with a duplicate inventory' do
        expect(FactoryGirl.build(:inventory, name: 'duplicate')).not_to be_valid
      end

      it 'is case insensitive' do
        expect(FactoryGirl.build(:inventory, name: 'Duplicate')).not_to be_valid
      end
    end
  end

  describe '#description' do
    it 'is valid when nil' do
      expect(FactoryGirl.build(:inventory, description: nil)).to be_valid
    end

    it 'is valid when under 256 characters' do
      expect(FactoryGirl.build(:inventory, description: Faker::Lorem.characters(255))).to be_valid
    end

    it 'is invalid when over 255 characters' do
      expect(FactoryGirl.build(:inventory, description: Faker::Lorem.characters(256))).not_to be_valid
    end
  end

  describe '#users' do
    it 'returns users belonging to the inventory' do
      inventory = FactoryGirl.create(:inventory)
      users = FactoryGirl.create_list(:user, 2, inventories: [inventory])
      expect(inventory.users).to match_array(users)
    end
  end

  describe '#owner' do
    it 'is invalid when nil' do
      expect(FactoryGirl.build(:inventory, owner: nil)).not_to be_valid
    end

    it 'can be a user' do
      user = FactoryGirl.create(:user)
      inventory = FactoryGirl.create(:inventory, owner: user)
      expect(inventory.owner_type).to eq('User')
    end

    it 'can be an organization' do
      organization = FactoryGirl.create(:organization)
      inventory = FactoryGirl.create(:inventory, owner: organization)
      expect(inventory.owner_type).to eq('Organization')
    end
  end

  describe 'user queries' do
    before(:all) do
      @inventory = FactoryGirl.create(:inventory)
      @admin = FactoryGirl.create(:user)
      @writer = FactoryGirl.create(:user)
      @reader = FactoryGirl.create(:user)
      @unconfirmed_user = FactoryGirl.create(:user)
      FactoryGirl.create(:inventory_user, :confirmed, user: @admin, inventory: @inventory, user_role: 'admin')
      FactoryGirl.create(:inventory_user, :confirmed, user: @writer, inventory: @inventory, user_role: 'write')
      FactoryGirl.create(:inventory_user, :confirmed, user: @reader, inventory: @inventory, user_role: 'read')
      FactoryGirl.create(:inventory_user, user: @unconfirmed_user, inventory: @inventory)
    end

    describe '#admins' do
      it 'returns confirmed users with with a user_role of admin' do
        expect(@inventory.admins).to eq([@admin])
      end
    end

    describe '#writers' do
      it 'returns confirmed users with a user_role of write' do
        expect(@inventory.writers).to eq([@writer])
      end
    end

    describe '#readers' do
      it 'returns confirmed users with a user_role of read' do
        expect(@inventory.readers).to eq([@reader])
      end
    end

    describe '#invited_users' do
      it 'returns unconfirmed users invited to the inventory' do
        expect(@inventory.invited_users).to eq([@unconfirmed_user])
      end
    end
  end
end
