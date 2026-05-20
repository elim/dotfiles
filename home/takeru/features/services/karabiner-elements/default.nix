{
  config,
  lib,
  dotfiles,
  ...
}:

let
  configDir = "${dotfiles}/home/${config.home.username}/features/services/karabiner-elements/config";
  targetDir = "${config.xdg.configHome}/karabiner";
in
{
  home.activation.linkKarabinerElementsConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}"
    $DRY_RUN_CMD rm -rf "${targetDir}"
    $DRY_RUN_CMD ln -s "${configDir}" "${targetDir}"

    /bin/launchctl kickstart -k gui/$(/usr/bin/id -u)/org.pqrs.service.agent.karabiner_console_user_server 2>/dev/null || true
  '';
}
