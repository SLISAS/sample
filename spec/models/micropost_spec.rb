require "rails_helper"
require "spec_helper"

RSpec.describe Micropost, type: :model do
  #  マイクロポスト
  describe "mictopost association" do
    before { user.save }
    # 今日の投稿・昨日の投稿
    subject(:new_post) { FactoryBot.create(:user_post, :today, user: user) }
    subject(:old_post) { FactoryBot.create(:user_post, :yesterday, user: user) }

    # 降順に表示される
    it "order descending" do
      new_post
      old_post
      expect(user.microposts.count).to eq 2
      expect(Micropost.all.count).to eq user.microposts.count
      expect(user.microposts.to_a).to eq [new_post, old_post]
    end

    # ユーザー削除と同時にマイクロポストも削除
    it "should destroy micropost depend on destroy user" do
      new_post
      old_post
      my_posts = user.microposts.to_a
      user.destroy
      # ユーザはマイクロポストを持っている
      expect(my_posts).not_to be_empty
      user.microposts.each do |post|
        expect(Micropost.where(id: post.id)).to be_empty
      end
    end
  end
end
