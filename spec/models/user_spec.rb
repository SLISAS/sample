# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

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
    describe "presence" do
      it { should validate_presence_of :name }
      it { should validate_presence_of :email }
      context "when pass and confirmation is not present" do
        before { user.password = user.password_confirmation = " " }
        it { should_not be_valid }
      end
    end

    describe "characters" do
      it { should validate_length_of(:name).is_at_most(50) }
      it { should validate_length_of(:email).is_at_most(255) }
      it { should validate_length_of(:password).is_at_least(6) }
    end

    describe "email format" do
      context "when invalid format" do
        it "should be invalid" do
          invalid_addr = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
          invalid_addr.each do |addr|
            user.email = addr
            expect(user).not_to be_valid
          end
        end
      end

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

    describe "email uniqueness" do
      context "when email is dup and upcase" do
        it "should already taken (uniqueness case insensitive)" do
          user = User.create(name: "foobar", email: "foo@bar.com", password: "foobar")
          dup_user = User.new(name: user.name, email: user.email.upcase, password: user.password)
          expect(dup_user).not_to be_valid
          expect(dup_user.errors[:email]).to include("has already been taken")
        end
      end

      context "when mixed-case" do
        let(:mixed_case_email) { "Foo@exampLE.COM" }
        it "should be saved as lower-case" do
          user.email = mixed_case_email
          user.save
          expect(user.reload.email).to eq mixed_case_email.downcase
        end
      end
    end
  end
  describe "has_secure_password" do
    context "when mismatched confirmation" do
      before { user.password_confirmation = "mismatch" }
      it { should_not be_valid }
    end
  end

  describe "authenticate? method" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }
    context "when valid password" do
      it "success authentification" do
        should eq found_user.authenticate(user.password)
      end
      it { is_expected.to be_truthy }
      it { is_expected.to be_valid }
    end

    context "when invalid password" do
      let(:incorrect) { found_user.authenticate("aaaaaaa") }
      it "fail authentication" do
        should_not eq incorrect
      end
      it { expect(incorrect).to be_falsey }
    end
  end
  describe "mictopost association" do
    before { user.save }
    subject(:new_post) { FactoryBot.create(:user_post, :today, user: user) }
    subject(:old_post) { FactoryBot.create(:user_post, :yesterday, user: user) }

    it "order descending" do
      new_post
      old_post
      expect(user.microposts.count).to eq 2
      expect(Micropost.all.count).to eq user.microposts.count
      expect(user.microposts.to_a).to eq [new_post, old_post]
    end

    it "should destroy micropost depend on destroy user" do
      new_post
      old_post
      my_posts = user.microposts.to_a
      user.destroy
      expect(my_posts).not_to be_empty
      user.microposts.each do |post|
        expect(Micropost.where(id: post.id)).to be_empty
      end
    end
  end
end
