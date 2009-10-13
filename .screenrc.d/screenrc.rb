#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-

############################################################
### libraries

# require 'rubygems'
# require 'pit'


############################################################
### functions

def screen(args)
  exec('screen', '-X', 'eval', *args)
end

def make_sh_wrapper(opts = {})
  title  = opts[:title]  && "-t   #{opts[:title]}"
  number = opts[:number]
  dir    = opts[:dir]    && "cd   #{opts[:dir]} &&"
  env    = opts[:env]    && "eval #{opts[:env]}"
  prog   = opts[:prog]   && "exec #{opts[:prog]}"
  args   = opts[:args]

  "screen #{title} #{number} sh -c '#{dir} #{env} #{prog} #{args}'"
end

############################################################
### main

session_name = ENV['STY'].gsub(/.+?\.(.+)/, '\1')
commands = []

commands.instance_eval do |c|
  ## encoding
  encoding = 'UTF-8'
  push 'defutf8 on'
  push 'cjkwidth on'
  push "defencoding #{encoding}"
  push "encoding #{encoding} #{encoding}"

  ## hardstatus
  push %W(
    hardstatus alwayslastline
    "%{= KC}[%H:#{session_name}]
    %<%{= KW}%-Lw%{= WK}%50>%n%f*
    %t%{-}%+Lw%<%{= KY} %Y-%m-%d %c").join(' ')

  ## startup programs
  case session_name
  when 'daemon'
    push make_sh_wrapper({
        :title  => 'dbcli.py',
        :prog   => '/usr/local/bin/dbcli.py',
        :args   => 'status',
        :number => 1
      })

    push make_sh_wrapper({
        :title  => 'wig.rb',
        :dir    => '~/src/lang/ruby/net-irc/examples',
        :prog   => './wig.rb',
        :args   => '--debug',
        :number => 2
      })
    push make_sh_wrapper({
        :title  => 'tig.rb',
        :dir    => '~/src/lang/ruby/net-irc/examples',
        :prog   => './tig.rb',
        :args   => '--debug',
        :number => 3
      })

    push make_sh_wrapper({
        :title  => 'tiarra',
        :dir    => '~/.tiarra',
        :prog   => '~/src/lang/perl/tiarra/tiarra',
        :number => 5
      })

    push make_sh_wrapper({
        :title  => 'tiarra',
        :dir    => '~/.tiarra',
        :prog   => '~/src/lang/perl/tiarra/tiarra',
        :args   => '--config=fetch-title-bot.conf --debug',
        :number => 6
      })

    push make_sh_wrapper({
        :title  => 'mobirc',
        :dir    => '~/src/lang/perl/mobirc',
        :env    => 'DEBUG=1',
        :prog   => './mobirc',
        :number => 7
      })

    push make_sh_wrapper({
        :title  => 'fastri',
        :prog   => 'fastri-server',
        :number => 8
      })

  when 'rails'
    push make_sh_wrapper({
        :title  => 'console',
        :prog   => './script/console',
        :number => 3
      })

    push make_sh_wrapper({
        :title  => 'server',
        :prog   => './script/server',
        :number => 4
      })

  end

  push 'select 0'

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
