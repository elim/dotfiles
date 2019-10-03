#!/usr/bin/osascript -l JavaScript

function buildCommand(argv) {
  // The sh requires the full path of tmux
  const tmux = argv.shift()
  const cdTo = argv.shift()
  const sessionName = argv.shift()
  const isSessionExists = argv.shift() === 'true'
  const extraCommand = argv.join(' ')

  let tmuxCommand = [
    `exec ${tmux}`,
    `${isSessionExists ? 'attach-session -t' : 'new-session -s'} ${sessionName}`
  ]

  if (extraCommand) {
    tmuxCommand.push(`${isSessionExists ? '\\; new-window' : ''} '${extraCommand}'`)
  }

  tmuxCommand.push(`\\; set-option set-titles-string ${sessionName}`)

  return [
    `cd ${cdTo}`,
    tmuxCommand.join(' ')
  ]
}

function createSession() {
  const iTerm = Application('iTerm')
  const window = iTerm.currentWindow()
  const tab = window.createTab({ withProfile: 'Default', command: 'sh'})

  return tab.currentSession
}

function run(argv) {
  const command = buildCommand(argv)
  const session = createSession()

  session.select()
  command.forEach(c => session.write({text: c }))
}
