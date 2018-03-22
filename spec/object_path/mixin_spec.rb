RSpec.describe ObjectPath::Mixin do

  let(:sample_class) {
    Class.new do
      include ObjectPath::Mixin
    end
  }

  it "instantiates" do
    sample_class.new
  end

end
