require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.create(:user) }

  it 'has a valid factory' do
    expect(user).to be_valid
  end

  describe '#username' do
    it 'is valid when under 26 characters' do
      expect(FactoryGirl.build(:user, username: Faker::Lorem.characters(25))).to be_valid
    end

    it 'is invalid when nil' do
      expect(FactoryGirl.build(:user, username: nil)).not_to be_valid
    end

    it 'is invalid when over 25 characters' do
      expect(FactoryGirl.build(:user, username: Faker::Lorem.characters(26))).not_to be_valid
    end

    describe 'uniqueness' do
      before do
        FactoryGirl.create(:user, username: 'duplicate')
      end

      it 'is invalid with a duplicate username' do
        expect(FactoryGirl.build(:user, username: 'duplicate')).not_to be_valid
      end

      it 'is case insensitive' do
        expect(FactoryGirl.build(:user, username: 'Duplicate')).not_to be_valid
      end
    end
  end

  describe '#confirmed' do
    it 'is true in a confirmed user' do
      expect(FactoryGirl.build(:user, :confirmed).confirmed?).to be true
    end

    it 'is false in an unconfirmed user' do
      expect(FactoryGirl.build(:user).confirmed?).to be false
    end
  end

  describe '#organizations' do
    it 'returns organizations it belongs to' do
      orgs = FactoryGirl.create_list(:organization, 2, users: [user])
      expect(user.organizations).to match_array(orgs)
    end
  end

  describe '#owned_organizations' do
    it 'returns organizations it owns' do
      orgs = FactoryGirl.create_list(:organization, 2, owner: user)
      expect(user.owned_organizations).to match_array(orgs)
    end
  end

  describe '#owned_inventories' do
    it 'returns inventories it owns' do
      inventories = FactoryGirl.create_list(:inventory, 2, owner: user)
      expect(user.owned_inventories).to match_array(inventories)
    end
  end

  describe '.search' do
    it 'can find a user through a case insensitive email' do
      expect(User.search(user.email.upcase).first).to eq(user)
    end

    it 'can find a user through a case insensitive username' do
      expect(User.search(user.username.upcase).first).to eq(user)
    end

    it 'is limited to 5 results' do
      FactoryGirl.create_list(:user, 6)
      expect(User.search('@').length).to eq(5)
    end
  end

  describe '#inventory_access?' do
    let(:inventory) { FactoryGirl.create(:inventory) }

    shared_examples 'successful access' do |user_role|
      it "returns true when asking for #{user_role} access" do
        expect(user.inventory_access?(user_role, inventory)).to eq(true)
      end
    end

    shared_examples 'failed access' do |user_role|
      it "returns nil when asking for #{user_role} access" do
        expect(user.inventory_access?(user_role, inventory)).to eq(nil)
      end
    end

    it 'returns nil until confirmed' do
      FactoryGirl.create(:inventory_user, user: user, inventory: inventory)
      expect(user.inventory_access?('read', inventory)).to eq(nil)
    end

    describe 'read privileges' do
      let!(:inventory_user) { FactoryGirl.create(:inventory_user, :confirmed, user: user, inventory: inventory) }
      include_examples 'successful access', 'read'
      include_examples 'failed access', 'write'
      include_examples 'failed access', 'admin'
    end

    describe 'write privileges' do
      let!(:inventory_user) do
        FactoryGirl.create(:inventory_user, :confirmed, user: user, inventory: inventory, user_role: 'write')
      end
      include_examples 'successful access', 'read'
      include_examples 'successful access', 'write'
      include_examples 'failed access', 'admin'
    end

    describe 'admin privileges' do
      let!(:inventory_user) do
        FactoryGirl.create(:inventory_user, :confirmed, user: user, inventory: inventory, user_role: 'admin')
      end
      include_examples 'successful access', 'read'
      include_examples 'successful access', 'write'
      include_examples 'successful access', 'admin'
    end
  end

  describe 'inventory queries' do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @confirmed_inventories = FactoryGirl.create_list(:inventory, 2)
      @pending_inventories = FactoryGirl.create_list(:inventory, 2, users: [@user])
      @confirmed_inventories.each do |inventory|
        FactoryGirl.create(:inventory_user, :confirmed, user: @user, inventory: inventory)
      end
    end

    describe '#inventories' do
      it 'returns inventories which have been confirmed' do
        expect(@user.inventories).to match_array(@confirmed_inventories)
      end
    end

    describe '#pending_inventories' do
      it 'returns inventories which have not been confirmed' do
        expect(@user.pending_inventories).to match_array(@pending_inventories)
      end
    end
  end
end
