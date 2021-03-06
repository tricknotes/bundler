require "spec_helper"

describe "bundle open" do
  before :each do
    install_gemfile <<-G
      source "file://#{gem_repo1}"
      gem "rails"
    G
  end

  it "opens the gem with BUNDLER_EDITOR as highest priority" do
    bundle "open rails", :env => {"EDITOR" => "echo editor", "VISUAL" => "echo visual", "BUNDLER_EDITOR" => "echo bundler_editor"}
    expect(out).to eq("bundler_editor #{default_bundle_path('gems', 'rails-2.3.2')}")
  end

  it "opens the gem with VISUAL as 2nd highest priority" do
    bundle "open rails", :env => {"EDITOR" => "echo editor", "VISUAL" => "echo visual", "BUNDLER_EDITOR" => ""}
    expect(out).to eq("visual #{default_bundle_path('gems', 'rails-2.3.2')}")
  end

  it "opens the gem with EDITOR as 3rd highest priority" do
    bundle "open rails", :env => {"EDITOR" => "echo editor", "VISUAL" => "", "BUNDLER_EDITOR" => ""}
    expect(out).to eq("editor #{default_bundle_path('gems', 'rails-2.3.2')}")
  end

  it "complains if no EDITOR is set" do
    bundle "open rails", :env => {"EDITOR" => "", "VISUAL" => "", "BUNDLER_EDITOR" => ""}
    expect(out).to eq("To open a bundled gem, set $EDITOR or $BUNDLER_EDITOR")
  end

  it "complains if gem not in bundle" do
    bundle "open missing", :env => {"EDITOR" => "echo editor", "VISUAL" => "", "BUNDLER_EDITOR" => ""}
    expect(out).to match(/could not find gem 'missing'/i)
  end

  it "suggests alternatives for similar-sounding gems" do
    bundle "open Rails", :env => {"EDITOR" => "echo editor", "VISUAL" => "", "BUNDLER_EDITOR" => ""}
    expect(out).to match(/did you mean rails\?/i)
  end
end
