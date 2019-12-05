# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

# 属性・メソッドの検証
shared_examples_for "User-model respond to attribute or method" do
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:remember_digest) }
  it { should respond_to(:activation_digest) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  # it { should respond_to(:feed) }
end

RSpec.describe User, type: :model do
  subject(:user) { FactoryBot.build(:user) }

  it { should be_valid }

  it_behaves_like "User-model respond to attribute or method"

  describe "validations" do
    # 存在性
    describe "presence" do
      # 名前・メール
      it { should validate_presence_of :name }
      it { should validate_presence_of :email }
      # パスワード・confirmation
      context "when pass and confirmation is not present" do
        before { user.password = user.password_confirmation = " " }
        it { should_not be_valid }
      end
    end
    # 文字数
    describe "characters" do
      it { should validate_length_of(:name).is_at_most(50) }
      it { should validate_length_of(:email).is_at_most(255) }
      it { should validate_length_of(:password).is_at_least(6) }
    end

    # メールのフォーマット
    describe "email format" do
      # 無効
      context "when invalid format" do
        it "should be invalid" do
          invalid_addr = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
          invalid_addr.each do |addr|
            user.email = addr
            expect(user).not_to be_valid
          end
        end
      end

      # 有効
      context "when valid format" do
        it "should be valid" do
          valid_addr = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
          valid_addr.each do |addr|
            user.email = addr
            expect(user).to be_valid
          end
        end
      end
    end

    # ユニークなアドレス
    describe "email uniqueness" do
      # duplicate
      context "when email is dup and upcase" do
        it "should already taken (uniqueness case insensitive)" do
          user = User.create(name: "foobar", email: "foo@bar.com", password: "foobar")
          dup_user = User.new(name: user.name, email: user.email.upcase, password: user.password)
          expect(dup_user).not_to be_valid
          expect(dup_user.errors[:email]).to include("has already been taken")
        end
      end

      # 大文字・小文字の混在
      context "when mixed-case" do
        let(:mixed_case_email) { "Foo@exampLE.COM" }
        # 混在していても小文字で保存される
        it "should be saved as lower-case" do
          user.email = mixed_case_email
          user.save
          expect(user.reload.email).to eq mixed_case_email.downcase
        end
      end
    end
  end

  # パスワード認証
  describe "has_secure_password" do
    context "when mismatched confirmation" do
      before { user.password_confirmation = "mismatch" }
      it { should_not be_valid }
    end
  end

  # パスワード認証
  describe "authenticate? method" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }
    # 有効なパスワード
    context "when valid password" do
      # 認証成功シナリオ
      it "success authentification" do
        should eq found_user.authenticate(user.password)
      end
      it { is_expected.to be_truthy }
      it { is_expected.to be_valid }
    end

    # 無効なパスワード
    context "when invalid password" do
      let(:incorrect) { found_user.authenticate("aaaaaaa") }
      # 認証失敗シナリオ
      it "fail authentication" do
        should_not eq incorrect
      end
      it { expect(incorrect).to be_falsey }
    end
  end

  describe "follow and unfollow" do
    let(:following) { FactoryBot.create_list(:other_user, 30) }
    let(:not_following) { FactoryBot.create(:other_user) }
    before do
      user.save
      following.each do |u|
        user.follow(u)
        u.follow(user)
      end
    end

    describe "follow" do
      it "ユーザーが、他のユーザーをフォローしている" do
        following.each do |u|
          expect(user.following?(u)).to be_truthy
        end
      end
      it "user is following other-user (follow method)" do
        following.each do |u|
          expect(user.following).to include(u)
        end
      end
      it "other-users following include user (follow method)" do
        following.each do |u|
          expect(u.followers).to include(user)
        end
      end
    end
    describe "#unfollow" do
      before do
        following.each do |u|
          user.unfollow(u)
        end
      end

      it "他のユーザーをフォローしていないユーザー" do
        following.each do |u|
          expect(user.following?(u)).to be_falsey
        end
      end

      it "users following does not include other-user" do
        following.each do |u|
          expect(user.following).not_to include(u)
        end
      end

      it "other-users followers does not include user" do
        following.each do |u|
          expect(u.followers).not_to include(user)
        end
      end
    end
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
end
