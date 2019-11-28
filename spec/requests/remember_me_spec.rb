

require "spec_helper"
require "rails_helper"

RSpec.describe "Remember me", type: :request do
  let(:user) { FactoryBot.create(:user) }

  context "when valid information" do
    it "logs in with valid information followed by logout" do
      log_in_as(user)
      expect(responce).to redirect_to user_path(user)

      delete logout_path
      expect(response).to redirect_to root_path
      expect(session[:user_id]).to eq nil
    end
  end

  context "when login with remembering" do
    it "does remember cookies" do
      post login_path, params: { session: { email: user.email,
                                            password: user.password, remember_me: "1" } }
      expect(response.cookies["remember_me"]).to_not eq nil
    end
  end

  context "when login without remembering" do
    it "doesnt remember cookies" do
      post login_path, params: { session: { email: user.email,
                                            password: user.password, remember_me: "1" } }
      delete logout_path
      post login_path, params: { session: { email: user.email,
                                            password: user.password, remember_me: "0" } }
      expect(response.cookies["remember_token"]).to eq nil
    end
  end
end
