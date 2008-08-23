#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-

############################################################
## functions

def screen_eval(str, exec = false)
  if exec
    exec('screen', '-X', 'eval', str)
  else
    system('screen', '-X', 'eval', str)
  end
end

def startup?
  not not %x(screen -ls).match(/\t#{Process.ppid}\./)
end


############################################################
## variables

session_name = ENV['STY'].gsub(/.+?\.(.+)/, '\1')

############################################################
## encoding

case PLATFORM
when /cygwin/
  enc = 'SJIS'
else
  enc = 'UTF-8'
end

screen_eval "defutf8 #{enc == 'UTF-8' ? 'on' : 'off'}"
screen_eval "defencoding #{enc}"
screen_eval "encoding #{enc} #{enc}"
screen_eval 'cjkwidth on' if enc == 'UTF-8'

############################################################
## hardstatus

hardstatus = %Q(hardstatus alwayslastline ) +
                %Q("%{= KC}[%H:#{session_name}] ) +
                %Q(%<%{= KW}%-Lw%{= WK}%50>%n%f* %t%{-}%+Lw%<%{= KY} %Y-%m-%d %c")

screen_eval hardstatus

############################################################
## startup

if startup?
   case session_name
    when 'daemon'
    when 'rails'
     screen_eval 'screen 4 ./script/server'
     screen_eval 'screen 3 ./script/console'
     screen_eval 'select 0'
   end
end

############################################################
## zombie
case session_name
when *%w(daemon rails)
  screen_eval 'zombie QR', :exec
end
