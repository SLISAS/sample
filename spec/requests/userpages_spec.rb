# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

RSpec.describe "User pages", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  describe "GET #new" do
  end

  describe "GET #show" do
  end

  describe "#edit" do
    context "when authorized user" do
      it "responds successfully" do
        sign_in_as user
        get edit_user_path(user)
        expect(response).to be_success
        expect(response).to have_http_status "200"
      end
    end

    context "when not log in" do
      it "redirects to the login page" do
        get edit_user_path(user)
        expect(response).to have_http_status "200"
        expect(response).to redirect_to login_path
      end
    end

    context "when other user" do
      it "redirects to the login page" do
        log_in_as other_user
        get edit_user_path(user)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "#update" do
    context "when authorized user" do
      it "updates a user" do
        user_params = FactoryBot.attributes_for(:user, name: "NewName")
        log_in_as user
        patch user_path(user), params: { id: user.id, user: user_params }
        expect(user.reload.name).to eq("NewName")
      end
    end

    context "when not log in" do
      it "redirects to the login page" do
        user_params = FactoryBot.attributes_for(:user, name: "Newname")
        patch user_path(user), params: { id: user.id, user: user_params }
        expect(response).to have_http_status "302"
        expect(resoinse).to redirect_to login_path
      end
    end

    context "when other user" do
      it "does not update this user" do
        user_params = FactoryBot.attributes_for(:user, name: "NewName")
        log_in_as other_user
        patch user_path(user), params: { id: user.id, user: user_params }
        expect(response).to redirect_to root_path
      end
    end
  end
end
