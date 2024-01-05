# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.

describe Samovar::Options do
	let(:options) do
		subject.parse do
			option '-x <value>', "The x factor", default: 2
			option '-y <value>', "The y factor"
			
			option '--symbol <value>', "A symbol", type: Symbol
			option '--multi <value>', "You can pass multiple values of this flag", multi: true
			option '--multinum <value>', "Multiple numbers", type: Integer, multi: true
		end
	end
	
	it "should set defaults" do
		values = options.parse([], nil, nil)
		expect(values).to be == {x: 2}
	end
	
	it "should preserve current values" do
		values = options.parse([], nil, {x: 1, y: 2, z: 3})
		expect(values).to be == {x: 1, y: 2, z: 3}
	end
	
	it "should update specified values" do
		values = options.parse(['-x', 10], nil, {x: 1, y: 2, z: 3})
		expect(values).to be == {x: 10, y: 2, z: 3}
	end
	
	it "converts to symbol" do
		values = options.parse(['--symbol', 'thing'], {})
		expect(values[:symbol]).to be == :thing
	end
	
	it 'picks the last value of an argument by default' do
		values = options.parse(['--symbol', 'thing1', '--symbol', 'thing2'], {})
		expect(values[:symbol]).to be == :thing2
	end
	
	it 'appends arguments when multi is set' do
		values = options.parse(['--multi', 'thing1', '--multi', 'thing2'], {})
		expect(values[:multi]).to be == ['thing1', 'thing2']
	end
	
	it 'can handle type coersions with multi' do
		values = options.parse(['--multinum', '1', '--multinum', '8'])
		expect(values[:multinum]).to be == [1, 8]
	end
end
