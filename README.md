# Flopp

Flopp is a modern framework for building command-line tools and applications. It provides a declarative class-based DSL for building command-line parsers that include automatic documentation gneration `--help`. It helps you keep your functionality clean and isolated where possible.

[![Build Status](https://secure.travis-ci.org/ioquatix/flopp.svg)](http://travis-ci.org/ioquatix/flopp)
[![Code Climate](https://codeclimate.com/github/ioquatix/flopp.svg)](https://codeclimate.com/github/ioquatix/flopp)
[![Coverage Status](https://coveralls.io/repos/ioquatix/flopp/badge.svg)](https://coveralls.io/r/ioquatix/flopp)

## Motivation

I've been using [Trollop](https://github.com/ManageIQ/trollop) and while it's not bad, it's hard to use for sub-commands in a way that generates nice documentation. It also has pretty limited support for complex command lines (e.g. nested commands, splits, matching tokens, etc). Flopp is a high level bridge between the command line and your code: it generates decent documentation, maps nicely between the command line syntax and your functions, and supports sub-commands using classes which are easy to compose.

One of the other issues I had with existing frameworks is testability. Most frameworks expect to have some pretty heavy logic directly in the binary executable, or at least don't structure your code in a way which makes testing easy. Flopp structures your command processing logic into classes which can be easily tested in isolation, which means that you can mock up and [spec your command-line executables easily](https://github.com/ioquatix/teapot/blob/master/spec/teapot/command_spec.rb).

## Installation

Add this line to your application's Gemfile:

	gem 'flopp'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install flopp

## Usage

The best example of a working Flopp command line is probably [Teapot](https://github.com/ioquatix/teapot/blob/master/lib/teapot/command.rb). Please feel free to submit other examples and I will link to them here.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Future Work

One area that I'd like to work on is line-wrapping. Right now, line wrapping is done by the terminal which is a bit ugly in some cases. There is a [half-implemented elegant solution](lib/flopp/output/line_wrapper.rb).

## License

Released under the MIT license.

Copyright, 2016, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
