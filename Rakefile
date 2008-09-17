#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-


if PLATFORM =~ /cygwin/
  require 'win32ole'

  home = %x(cygpath -d #{ENV['HOME']}).chomp

  fs = WIN32OLE.new('Scripting.FileSystemObject')
  sh = WIN32OLE.new('WScript.Shell')

  title = 'GNU Screen'
  prog  = fs.GetFile("#{home}\\bin\\ck.exe")
  conf  = "#{home}\\dotfiles\\.ck.config.js"
  arg   = %Q[-f #{conf} -e sh -c "screen -DRRS main"]

  dest = fs.BuildPath( sh.SpecialFolders('StartUp') , title + '.lnk')

  fs.DeleteFile(dest) if fs.FileExists(dest)

  sc = sh.CreateShortcut(dest)
  sc.TargetPath = prog.Path
  sc.Arguments = arg
  sc.WorkingDirectory = home
  sc.Description = 'GNU Screen on ck.'
  sc.save
end
