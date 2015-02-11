describe "eol-users-wrapper::default" do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before do
    # allow(File).to receive(:exists?)
    # stub_command("which sudo").and_return(0)
    # stub_search("users", "groups:dotfiles").and_return([])
  end

  it "includes users" do
    expect(chef_run).to include_recipe "users"
  end
end
