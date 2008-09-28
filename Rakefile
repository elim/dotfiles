# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-

require 'pathname'

task :default => [:dotfiles, :cygwin, :darwin]

dotfiles = FileList["./.*"].exclude(/\.$/).
  exclude(/\.git$/).
  exclude(/\.gitignore$/)

desc 'Deployment dotfiles.'
file :dotfiles => dotfiles do |d|
  dotdir = Dir::pwd
  Dir::chdir
  d.prerequisites.each do |fname|
    src =  Pathname.new("#{dotdir}/#{fname}").realpath
    dest = fname
    FileUtils::symlink(src, dest,
      {:force => true, :verbose => true})
  end
end

desc 'Deployed Login Item of Terminal.app.'
task :darwin do
  if PLATFORM =~ /darwin/
    prog = %x(which osascript).chomp # => "/usr/bin/osascript"
    args = []

    args.push '-e'
    args.push <<EOF
set appPath to "/Applications/Utilities/Terminal.app"

tell application "System Events"
  try
    delete (every login item whose name contains "Terminal.app")
  end try
    make new login item at end of login items \
      with properties {path:appPath, hidden:false, kind:Application}
end tell
EOF

    system prog, *args
  end
end


desc 'Deployed Shortcut of ck Terminal Emulartor to Start-Up folder.'
task :cygwin do
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
end
