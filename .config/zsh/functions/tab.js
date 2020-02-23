function buildCommand(argv) {
  // The sh requires the full path of tmux
  const tmux = argv.shift()
  const cdTo = argv.shift()
  const sessionName = argv.shift()
  const extraScript = argv.shift() || ''

  let tmuxCommand = [
    `exec ${tmux}`,
    `new-session -ADs ${sessionName} ${extraScript}`,
    `\\; set-option set-titles-string '${sessionName}'`
  ]

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
