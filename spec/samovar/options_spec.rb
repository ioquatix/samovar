
RSpec.describe Samovar::Options do
	subject(:options) do
		described_class.parse do
			option '-x <value>', "The x factor", default: 2
			option '-y <value>', "The y factor"
		end
	end
	
	it "should set defaults" do
		values = options.parse([], nil)
		expect(values).to be == {x: 2}
	end
	
	it "should preserve current values" do
		values = options.parse([], {x: 1, y: 2, z: 3})
		expect(values).to be == {x: 1, y: 2, z: 3}
	end
	
	it "should update specified values" do
		values = options.parse(['-x', 10], {x: 1, y: 2, z: 3})
		expect(values).to be == {x: 10, y: 2, z: 3}
	end
end