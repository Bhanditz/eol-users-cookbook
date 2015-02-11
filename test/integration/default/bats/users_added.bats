#!/usr/bin/env bats

@test "home directories installed" {
  run ls /home/jane
    [ "$status" -eq 0 ]
}


@test "unknown home directories don't exist" {
  run ls /home/unknown_user
    [ "$status" -eq 2 ]
}

@test "group sysadmin has all 3 users" {
  run cat /etc/group
  echo "$output" | grep sysadmin | grep john | grep jane |grep vagrant
}

@test "group dotfiles has 2 users only" {
  run cat /etc/group
  echo "$output" | grep dotfiles | grep john | grep vagrant
  echo "$output" | grep dotfiles | grep john | grep vagrant |grep -v jane
}
