require "rails_helper"

RSpec.describe "User pages", type: :request do
  let(:user) { FactroyBot.create(:user) }

  describe "GET #new" do
    it "returns http success" do
      get signup_path
      expect(response).to be_success
      expect(response).to have_http_status "200"
    end
  end

  describe "GET #show" do
    context "as an"
  end
end
