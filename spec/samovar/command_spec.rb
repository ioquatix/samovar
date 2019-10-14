# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'samovar'

module Samovar::CommandSpec
	class Bottom < Samovar::Command
		self.description = "Create a new teapot package using the specified repository."
		
		one :project_name, "The name of the new project in title-case, e.g. 'My Project'."
		many :packages, "Any additional packages you'd like to include in the project."
		split :argv, "Additional arguments to be passed to the sub-process."
	end

	class Top < Samovar::Command
		self.description = "A decentralised package manager and build tool."
		
		options do
			option '-c/--configuration <name>', "Specify a specific build configuration.", default: 'TEAPOT_CONFIGURATION'
			option '-i/--in/--root <path>', "Work in the given root directory."
			option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
			option '-h/--help', "Print out help information."
			option '-v/--version', "Print out the application version."
		end
		
		nested :command, {
			'bottom' => Bottom
		}
	end

	RSpec.describe Samovar::Command do
		it "should invoke call" do
			expect(Top).to receive(:new).and_wrap_original do |original_method, *arguments, &block|
				original_method.call(*arguments, &block).tap do |instance|
					expect(instance).to receive(:call)
				end
			end
			
			Top.call([])
		end
		
		it "should use default value" do
			top = Top[]
			expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
		end
		
		it "can update options" do
			top = Top[]
			expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
			
			top = top['--verbose']
			expect(top.options[:configuration]).to be == 'TEAPOT_CONFIGURATION'
			expect(top.options[:logging]).to be == :verbose
		end
		
		it "should parse a simple command" do
			top = Top["-c", "path", "bottom", "foobar", "A", "B", "--", "args", "args"]
			
			expect(top.options[:configuration]).to be == 'path'
			expect(top.command.class).to be == Bottom
			expect(top.command.project_name).to be == 'foobar'
			expect(top.command.packages).to be == ['A', 'B']
			expect(top.command.argv).to be == ["args", "args"]
		end
		
		it "should generate documentation" do
			top = Top[]
			buffer = StringIO.new
			top.print_usage(output: buffer)
			
			expect(buffer.string).to be_include(Top.description)
		end
	end
end
