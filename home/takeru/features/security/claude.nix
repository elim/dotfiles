{
  dotfiles,
  ...
}:
{
  # Claude Code API key
  "claude/api_key" = {
    sopsFile = "${dotfiles}/secrets/claude-api-key.yaml";
    key = "anthropic_api_key";
  };
}
