{ pkgs, ... }:

{
  home.packages = [
    pkgs.opencode
  ];

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    autoupdate = false;
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://127.0.0.1:11434/v1";
          timeout = 600000;
          chunkTimeout = 60000;
        };
        models = {
          "devstral-small-2:24b-instruct-2512-q4_K_M" = {
            name = "Devstral Small 2 24B Q4_K_M (local)";
          };
          "devstral-small-2:24b-instruct-2512-q8_0" = {
            name = "Devstral Small 2 24B Q8_0 (local)";
          };
          "gemma4:e2b" = {
            name = "Gemma 4 E2B (local)";
          };
          "gemma4:e4b" = {
            name = "Gemma 4 E4B (local)";
          };
          "gemma4:26b" = {
            name = "Gemma 4 26B A4B (local)";
          };
          "qwen3:4b" = {
            name = "Qwen3 4B (local)";
          };
          "qwen3-coder:30b" = {
            name = "Qwen3-Coder 30B A3B (local)";
          };
          "qwen3.6:27b-q4_K_M" = {
            name = "Qwen3.6 27B Q4_K_M (local)";
          };
          "qwen3.6:27b-q8_0" = {
            name = "Qwen3.6 27B Q8_0 (local)";
          };
          "qwen3.6:35b-a3b-q4_K_M" = {
            name = "Qwen3.6 35B A3B Q4_K_M (local)";
          };
          "qwen3.6:35b-a3b-q8_0" = {
            name = "Qwen3.6 35B A3B Q8_0 (local)";
          };
        };
      };
    };
    model = "ollama/devstral-small-2:24b-instruct-2512-q4_K_M";
    small_model = "ollama/qwen3:4b";
  };
}
