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

def make_sh_wrapper(hash)
  dir    = hash[:dir]    || '.'
  number = hash[:number] || ''
  env    = hash[:env]
  prog   = hash[:prog]
  arg    = hash[:arg]
  title  = hash[:title]

  ["screen",
    ("-t #{title}" if title),
    ("#{number}" if number),
    "sh -c '",
    ("cd #{dir} &&" if dir),
    ("eval #{env}" if env),
    prog,
    ("#{arg}" if arg),
    "'"
  ].join(' ')

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
      tiarraconf_path = File::expand_path %q(~/.tiarra)
      tiarra_path     = File::expand_path %q(~/src/lang/perl/tiarra)
      netirc_path     = File::expand_path %q(~/src/lang/ruby/net-irc)
      mobirc_path     = File::expand_path %q(~/src/lang/perl/mobirc)

      push make_sh_wrapper({
          :title  => "tiarra",
          :dir    => tiarraconf_path,
          :prog   => "#{tiarra_path}/tiarra",
          :number => 5
        })

      push make_sh_wrapper({
          :title  => "wig.rb",
          :dir    => netirc_path,
          :prog   => "examples/wig.rb",
          :arg    => "--debug",
          :number => 2
        })

      push make_sh_wrapper({
          :title  => "tig.rb",
          :dir    => netirc_path,
          :prog   => "examples/tig.rb",
          :arg    => "--debug",
          :number => 3
        })

      push make_sh_wrapper({
          :title  => "mobirc",
          :dir    => mobirc_path,
          :env    => "DEBUG=1",
          :prog   => "./mobirc",
          :number => 6
        })

    when "rails"
      push "screen 3 ./script/console"
      push "screen 4 ./script/server"
    end
    push "select 0" unless ENV['WINDOW'] == "0"
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
