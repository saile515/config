nvim() {
  local profile=""
  local profile_set=0
  local -a nvim_args=()

  while (( $# )); do
    case "$1" in
      --)
        nvim_args+=("$@")
        break
        ;;
      --profile)
        if (( $# < 2 )); then
          print -u2 -- 'Usage: nvim [--profile NAME] [options/files...]'
          return 2
        fi
        if (( profile_set )); then
          print -u2 -- 'Specify --profile only once.'
          return 2
        fi
        profile="$2"
        profile_set=1
        shift 2
        ;;
      --profile=*)
        if (( profile_set )); then
          print -u2 -- 'Specify --profile only once.'
          return 2
        fi
        profile="${1#--profile=}"
        profile_set=1
        shift
        ;;
      *)
        nvim_args+=("$1")
        shift
        ;;
    esac
  done

  if (( profile_set )); then
    case "$profile" in
      ''|*[!a-zA-Z0-9_-]*)
        print -u2 -- 'Invalid profile name; use letters, numbers, underscores, or hyphens.'
        return 2
        ;;
    esac
    command nvim --cmd "let g:nvim_profile = '$profile'" "${nvim_args[@]}"
  else
    command nvim "${nvim_args[@]}"
  fi
}
