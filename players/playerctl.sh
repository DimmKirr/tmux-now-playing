#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$(dirname "$CURRENT_DIR")/scripts/cache.sh"
source "$(dirname "$CURRENT_DIR")/scripts/helpers.sh"

is_running() {

  if (playerctl status | grep "No players found") then 
    return 1
  else # Player is found, but not playing (i.e. stopped or paused)
    return 0
  fi
}

is_playing() {
  if ! is_running; then # Isn't running 
    return 1
  fi

  local player_status="$(playerctl status)"

  if test "$player_status" = "Paused"; then
    return 1
  fi

  return 0
}

get_music_data() {

  local status="$(playerctl status ; sleep 1)"
  local title="$(playerctl metadata xesam:artist)"
  local artist="$(playerctl metadata xesam:title)"

  # MPRIS provides the length in us, then we will need to do a bit of math here.
   
  local duration="$(playerctl metadata mpris:length | awk '{printf("%d", int($1/1000000))}')"

  local position="$(playerctl position | cut -d. -f1)"

  local playerctl_status="$(playerctl status)"

  if test "$playerctl_status" = "Playing"; then
    status="playing"
  elif test "$playerctl_status" = "Paused"; then
    status="paused"
  fi

  printf "%s\n%s\n%s\n%s\n%s\nSpotify" "$status" "$position" "$duration" "$artist" "$title"
}

send_command() {
  local remote_command="$1"

  if test "$remote_command" = "pause"; then
    playerctl play-pause
  else
    playerctl "$remote_command"
  fi
}
