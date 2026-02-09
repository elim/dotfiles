{
  dotfiles,
  ...
}:
{
  # OpenAI API key for Codex CLI
  "openai/api_key" = {
    sopsFile = "${dotfiles}/secrets/openai.yaml";
    key = "api_key";
  };
}
