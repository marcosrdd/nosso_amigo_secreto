require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    sign_in @current_user
    @campaign = FactoryBot.create(:campaign, user: @current_user)
  end

  describe "GET #create" do
    before(:each) do
      @new_member_attributes = attributes_for(:member, campaign_id: @campaign.id)
      request.env["HTTP_ACCEPT"] = 'application/json'
      post :create, params: {member: @new_member_attributes}
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "Member has the correct data" do
      expect(Member.last.name).to eq(@new_member_attributes[:name])
      expect(Member.last.email).to eq(@new_member_attributes[:email])
    end
    it "Member is associated a correct campaign" do
      expect(Member.last.campaign).to eq(@campaign)
    end
    it "Cant have 2 member with the same email per campaign" do
      post :create, params: {member: @new_member_attributes}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end


  describe "DELETE #destroy" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end
    it "returns http success" do
        member = create(:member, campaign: @campaign)
        delete :destroy, params: {id: member.id}
        expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
      @new_member_attributes = attributes_for(:member, campaign_id: @campaign.id)
      member = create(:member, campaign_id: @campaign.id)
      put :update, params: {id: member.id, member: @new_member_attributes}
    end
   
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "Member has the new attributes" do
      expect(Member.last.name).to eq(@new_member_attributes[:name])
      expect(Member.last.email).to eq(@new_member_attributes[:email])
    end
    it "Cant have 2 member with the same email per campaign" do
      member = create(:member, campaign_id: @campaign.id)
      put :update, params: {id: member.id, member: @new_member_attributes}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT #opened" do
    before(:each) do
      @member = create(:member, campaign_id: @campaign.id)
      request.env["HTTP_ACCEPT"] = 'application/json'
      @member.set_pixel
    end
   
    it "Member is not opened when set pixel" do
      @member.reload
      expect(Member.last.open).to be(false)
    end

    it "Member is opened with the valid token" do
      get :opened, params: {token: @member.token}
      @member.reload
      expect(Member.last.open).to be_truthy
    end
  end

end
