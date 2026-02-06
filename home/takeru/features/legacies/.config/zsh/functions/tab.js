function buildCommand(argv) {
  const tmux = argv.shift();
  const cdTo = argv.shift();
  const tabName = argv.shift();
  const sessionName = argv.shift();
  const extraScript = argv.shift() || "";

  // Build tmux command
  let tmuxCommand = [
    `exec ${tmux}`,
    `new-session -ADs ${sessionName} ${extraScript}`,
    `\\; set-option set-titles-string '${tabName}'`,
  ];

  return [`cd ${cdTo}`, tmuxCommand.join(" ")];
}

function createSession() {
  const iTerm = Application("iTerm");
  const window = iTerm.currentWindow();
  // Use /usr/bin/env to set ZSH_NIX_MINIMAL environment variable
  // This loads only Nix environment without heavy initialization (keychain, etc.)
  const tab = window.createTab({
    withProfile: "Default",
    command: "/usr/bin/env ZSH_NIX_MINIMAL=1 zsh",
  });

  return tab.currentSession;
}

function run(argv) {
  const command = buildCommand(argv);
  const session = createSession();

  session.select();
  command.forEach((c) => session.write({ text: c }));
}
