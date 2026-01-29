{
  dotfiles,
  ...
}:

let
  sopsFile = "${dotfiles}/secrets/jobcan-slack.yaml";
in
{
  # Slack credentials for jobcan-slack tool
  "jobcan-slack/slack_token" = {
    inherit sopsFile;
    key = "slack_token";
  };
  "jobcan-slack/private_channel" = {
    inherit sopsFile;
    key = "private_channel";
  };
  "jobcan-slack/daily_report_channel" = {
    inherit sopsFile;
    key = "daily_report_channel";
  };
}
