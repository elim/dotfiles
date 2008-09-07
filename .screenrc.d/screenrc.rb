#!/usr/bin/env ruby

session_name = ENV['STY'].gsub(/.+?\.(.+)/, '\1')
status_format = %Q(hardstatus alwayslastline ) +
                %Q("%{= KC}[%H:#{session_name}] ) +
                %Q(%<%{= KW}%-Lw%{= WK}%50>%n%f* %t%{-}%+Lw%<%{= KY} %Y-%m-%d %c")

system("screen", "-X", "eval", status_format)

############################################################
## encoding

case PLATFORM
when /cygwin/
  enc = 'sjis'
else
  enc = 'utf8'
end

system("screen", "-X", "eval", "defutf8 #{enc == 'utf8' ? 'on' : 'off'}")
system("screen", "-X", "eval", "defencoding #{enc}")
system("screen", "-X", "eval", "encoding #{enc} #{enc}")

%w(daemon rails).each do |session_type|
  exec('screen', '-X', 'eval', 'zombie QR') if session_name == session_type
end
