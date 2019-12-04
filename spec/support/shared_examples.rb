
require "spec_helper"
require "rails_helper"

shared_examples_for "User-model respond to attribute or method" do
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:auhenticate) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:remember_digest) }
  it { should respond_to(:activation_digest) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
end
