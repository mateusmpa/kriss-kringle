require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @current_user = create(:user)
    sign_in @current_user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
     end
  end

  describe 'GET #show' do
    context 'campaign exists' do
      context 'user is the owner of the campaign' do
        it 'return http success' do
          campaign = create(:campaign, user: @current_user)
          get :show, params: { id: campaign.id }

          expect(response).to have_http_status(:success)
        end
      end

      context 'user is not the owner of the campaign' do
        it 'redirects to root path' do
          campaign = create(:campaign)
          get :show, params: { id: campaign.id }

          expect(response).to redirect_to('/')
        end
      end
    end

    context "campaign don't exists" do
      it 'redirects to root path' do
        get :show, params: { id: 0 }

        expect(response).to redirect_to('/')
      end
    end
  end

  describe 'POST #create' do
    before(:each) do
      @campaign_attributes = attributes_for(:campaign, user: @current_user)
      post :create, params: { campaign: @campaign_attributes }
    end

    it 'redirect to new campaign' do
      expect(response).to have_http_status(302)
      expect(response).to redirect_to("/campaigns/#{Campaign.last.id}")
    end

    it 'create campaign with right attributes' do
      expect(Campaign.last.user).to eq(@current_user)
      expect(Campaign.last.title).to eq(@campaign_attribures[:title])
      expect(Campaign.last.description).to eq(@campaign_attributes[:description])
      expect(Campaign.last.status).to eq('pending')
    end

    it 'create campaign with owner associated as a member' do
      expect(Campaign.last.members.last.name).to eq(@current_user.name)
      expect(Campaign.last.members.last.email).to eq(@current_user.email)
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    context 'user is the campaign owner' do
      it 'return http success' do
        campaign = create(:campaign, user: @current_user)
        delete :destroy, params: { id: campaign.id }

        expect(response).to have_http_status(:success)
      end
    end

    context "user isn't the campaign owner" do
      it 'return http forbidden' do
        campaign = create(:campaign)
        delete :destroy, params: { id: campaign.id }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'PUT #update' do
    before(:each) do
      @new_campaign_attributes = attributes_for(:campaign)
      request.env['HTTP_ACCEPT'] = 'application_json'
    end

    context 'user is the campaign owner' do
      before(:each) do
        campaign = create(:campaign, user: @current_user)
        put :update, params: { id: campaign.id, campaign: @new_campaign_attributes }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'campaign have the new attributes' do
        expect(Campaign.last.title).to eq(@new_campaign_attributes[:title])
        expect(Campaign.last.description).to eq(@new_campaign_attributes[:description])
      end
    end

    context "user isn't the campaign owner" do
      it 'returns http forbidden' do
        campaign = create(:campaign)
        put :update, params: { id: campaign.id, campaign: @new_campaign_attributes }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #raffle' do
    before(:each) do
      request.env['HTTP_ACCEPT'] = 'application_json'
    end

    context 'user is the campaign owner' do
      before(:each) do
        @campaign = create(:campaign, user: @current_user)
      end

      context 'has more than two members' do
        before(:each) do
          create(:member, campaign: @campaign)
          create(:member, campaign: @campaign)
          post :raffle, params: { id: @campaign.id }
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'no more than two members' do
        before(:each) do
          create(:member, campaign: @campaign)
          post :raffle, params: { id: @campaign.id }
        end

        it 'returns http unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "user isn't the campaign owner" do
      before(:each) do
        @campaign = create(:campaign)
      end

      it 'returns http forbidden' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
