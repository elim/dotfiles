#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-

############################################################
### functions

def screen_eval(args)
  exec('screen', '-X', 'eval', *args)
end

def startup?
  %x(screen -ls).match(/\t#{Process::ppid}\./) || $DEBUG
end


############################################################
### main

session_name = ENV['STY'].gsub(/.+?\.(.+)/, '\1')
commands = []

commands.instance_eval do |c|
  ## encoding

  case PLATFORM
  when /cygwin/
    encoding = 'SJIS'
  else
    encoding = 'UTF-8'
    push 'defutf8 on'
    push 'cjkwidth on'
  end

  push "defencoding #{encoding}"
  push "encoding #{encoding} #{encoding}"

  ## hardstatus

  push %W(
    hardstatus alwayslastline
    "%{= KC}[%H:#{session_name}]
    %<%{= KW}%-Lw%{= WK}%50>%n%f*
    %t%{-}%+Lw%<%{= KY} %Y-%m-%d %c").join(' ')

  ## startup

  if startup?
    case session_name
    when "daemon"
      pwd = Dir.pwd
      debug = ENV["DEBUG"]

      tiarraconf_path = File::expand_path %q(~/.tiarra)
      tiarra_path     = File::expand_path %q(~/src/lang/perl/tiarra)
      netirc_path     = File::expand_path %q(~/src/lang/ruby/net-irc/examples)
      mobirc_path     = File::expand_path %q(~/src/lang/perl/mobirc)

      push "chdir #{tiarraconf_path}"
      push "screen 5 #{tiarra_path}/tiarra"
      push "title tiarra"

      push "chdir #{netirc_path}"
      push "screen 2 ./wig.rb --debug"
      push "title wig"

      push "screen 3 ./tig.rb --debug"
      push "title tig"

      push "chdir #{mobirc_path}"
      push "setenv DEBUG 1"
      push "screen 6 ./mobirc"
      push "title mobirc"

      push debug ? "setenv DEBUG #{debug}" : "unsetenv DEBUG"

      push "chdir #{pwd}"

    when "rails"
      push "screen 3 ./script/console"
      push "screen 4 ./script/server"
    end
    push "select 0"
  end

  ## zombie
  case session_name
  when *%w(daemon rails)
    push 'zombie QR'
  end

end

if $DEBUG
  require 'pp'
  pp commands
else
  screen_eval commands
end
