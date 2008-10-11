#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-

############################################################
### functions

def screen(args)
  exec('screen', '-X', 'eval', *args)
end

def startup?
  %x(screen -ls).match(/\t#{Process::ppid}\./) || $DEBUG
end

def make_sh_wrapper(opts = {})
  title  = opts[:title]  && "-t   #{opts[:title]}"
  number = opts[:number]
  dir    = opts[:dir]    && "cd   #{File::expand_path(opts[:dir])} &&"
  env    = opts[:env]    && "eval #{opts[:env]}"
  prog   = opts[:prog]   && "exec #{File::expand_path(opts[:prog])}"
  args   = opts[:args]

  "screen %s %s sh -c '%s %s %s %s'" % [
    title, number, dir, env, prog, args
  ]
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
      push make_sh_wrapper({
          :title  => "wig.rb",
          :dir    => "~/src/lang/ruby/net-irc/examples",
          :prog   => "./wig.rb",
          :args   => "--debug",
          :number => 2
        })

      push make_sh_wrapper({
          :title  => "tig.rb",
          :dir    => "~/src/lang/ruby/net-irc/examples",
          :prog   => "./tig.rb",
          :args   => "--debug",
          :number => 3
        })

      push make_sh_wrapper({
          :title  => "tiarra",
          :dir    => "~/.tiarra",
          :prog   => "~/src/lang/perl/tiarra/tiarra",
          :number => 5
        })

      push make_sh_wrapper({
          :title  => "mobirc",
          :dir    => "~/src/lang/perl/mobirc",
          :env    => "DEBUG=1",
          :prog   => "./mobirc",
          :number => 6
        })

      push make_sh_wrapper({
          :title  => "fastri",
          :prog   => "fastri-server",
          :number => 8
        })

      push "select 0"

    when "rails"
      push "screen 3 ./script/console"
      push "screen 4 ./script/server"
      push "select 0"
    end
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
  screen commands
end
