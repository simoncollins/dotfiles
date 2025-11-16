tools() {
  echo
  grep '^[[:blank:]]*#' ~/.config/mise/config.toml | sed 's/^[[:blank:]]*# *//' | sed $'s/^\\([^:]*\\):/\033[1;34m\\1\033[0m:/' | sort
  echo
}

