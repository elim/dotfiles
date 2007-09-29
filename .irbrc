#!/usr/bin/env ruby
# $Id: .irbrc 82 2006-04-01 17:29:35Z takeru $
# Copyright (c) 2006 Takeru Naito <takeru@at-mac.com>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'irb/completion'
require 'kconv'

IRB.conf[:EVAL_HISTORY] = 32

module Kernel
  def r(arg)
    puts_utf8(`refe #{arg}`)
  end
  private :r
end

class Module
  def r(meth = nil)
    if meth
      if instance_methods(false).include? meth.to_s
        puts_utf8(`refe #{self}##{meth}`)
      else
        super
      end
    else
      puts_utf8(`refe #{self}`)
    end
  end
end

def puts_utf8(str)
  puts str.kconv(Kconv::UTF8, Kconv::EUC)
end
