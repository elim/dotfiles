{ config, pkgs, ... }:

let
  jobcan-slack = pkgs.writeShellScriptBin "jobcan-slack" ''
    set -euo pipefail

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    # Usage function
    usage() {
      echo -e "''${BLUE}jobcan-slack''${NC} - Control Jobcan via Slack"
      echo ""
      echo -e "''${YELLOW}Usage:''${NC}"
      echo "  jobcan-slack --jt    Clock in/out + work time query"
      echo "  jobcan-slack --jw    Work time query only"
      echo ""
      echo -e "''${YELLOW}Options:''${NC}"
      echo "  --jt           Execute /jobcan_touch + /jobcan_worktime"
      echo "  --jw           Execute /jobcan_worktime only"
      echo "  -h, --help     Show this help message"
      echo ""
      echo -e "''${YELLOW}Shell Aliases:''${NC}"
      echo "  alias jt='jobcan-slack --jt'"
      echo "  alias jw='jobcan-slack --jw'"
      echo ""
      echo -e "''${YELLOW}Examples:''${NC}"
      echo "  jobcan-slack --jt    # Clock in/out and check work time"
      echo "  jt                   # Using alias"
      echo "  jw                   # Work time query only"
    }

    # Read secrets from sops-nix managed paths
    TOKEN=$(cat "${config.sops.secrets."jobcan-slack/slack_token".path}")
    PRIVATE_CHANNEL=$(cat "${config.sops.secrets."jobcan-slack/private_channel".path}")
    DAILY_REPORT_CHANNEL=$(cat "${config.sops.secrets."jobcan-slack/daily_report_channel".path}")

    # API call function with error handling
    api_call() {
      local command=$1
      local channel=$2
      local response

      echo -e "''${YELLOW}Sending $command to channel $channel...''${NC}"

      response=$(${pkgs.curl}/bin/curl -sSf -XPOST \
        -d "token=$TOKEN" \
        -d "channel=$channel" \
        -d "command=$command" \
        "https://slack.com/api/chat.command" 2>&1)

      if [ $? -ne 0 ]; then
        echo -e "''${RED}Error: API call failed''${NC}" >&2
        echo "$response" >&2
        return 1
      fi

      # Check if Slack API returned ok: true
      if echo "$response" | ${pkgs.jq}/bin/jq -e '.ok == true' > /dev/null 2>&1; then
        echo -e "''${GREEN}✓ Success''${NC}"
        return 0
      else
        echo -e "''${RED}✗ API returned error''${NC}" >&2
        echo "$response" | ${pkgs.jq}/bin/jq '.' >&2
        return 1
      fi
    }

    # Main execution
    main() {
      local exit_code=0
      local mode=""

      # Parse arguments
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --jt)
            mode="touch_and_worktime"
            shift
            ;;
          --jw)
            mode="worktime_only"
            shift
            ;;
          -h|--help)
            usage
            exit 0
            ;;
          *)
            echo -e "''${RED}Error: Unknown option: $1''${NC}" >&2
            echo ""
            usage
            exit 1
            ;;
        esac
      done

      # If no mode specified, show usage
      if [ -z "$mode" ]; then
        usage
        exit 0
      fi

      # Execute based on mode
      case "$mode" in
        touch_and_worktime)
          if ! api_call "/jobcan_touch" "$DAILY_REPORT_CHANNEL"; then
            exit_code=1
          fi
          if ! api_call "/jobcan_worktime" "$PRIVATE_CHANNEL"; then
            exit_code=1
          fi
          ;;
        worktime_only)
          if ! api_call "/jobcan_worktime" "$PRIVATE_CHANNEL"; then
            exit_code=1
          fi
          ;;
      esac

      return $exit_code
    }

    main "$@"
  '';
in
{
  home.packages = [ jobcan-slack ];
}
