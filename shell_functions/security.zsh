# List api keys
list-api-keys() {
  echo "Stored API key services:"
  # Finds generic passwords where Account == Current User
  security find-generic-password -a "$(whoami)" 2>/dev/null \
  | grep -E '^\s+"svce"<blob>=' \
  | cut -d= -f2 \
  | tr -d '"' \
  | sed 's/^/  • /' \
  | sort
}

# Store an API key in the keychain - can be piped from pbpaste or entered on STDIN
store-api-key() {
  if [[ -z "$1" ]]; then
    echo "Usage: store-api-key <keychain-service> [api-key]"
    echo "        If [api-key] omitted → reads from stdin (pbpaste | …)"
    return 1
  fi

  local service="$1"
  local key=""

  if [[ -n "$2" ]]; then
    key="$2"
  else
    if [[ -t 0 ]]; then
      echo "No key provided and nothing piped in."
      echo "Try: pbpaste | store-api-key $service"
      return 1
    fi
    read -r key || return 1
    key="${key%$'\n'}"
    key="${key%$'\r'}"
  fi

  [[ -z "$key" ]] && { echo "Empty key – aborting"; return 1; }

  # CHANGE: -a is now "$(whoami)" instead of "$service"
  security add-generic-password -a "$(whoami)" -s "$service" -w "$key" -U

  echo "✅ API key stored for service: $service"
  echo "   Account: $(whoami)"
}

# Fetch and API key and store in env var
get-api-key() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: get-api-key <keychain-service> <env-var-name>"
    echo "Example: get-api-key myapp OPENAI_API_KEY"
    return 1
  fi

  local service="$1"
  local env_name="$2"
  local key

  # CHANGE: Added -a "$(whoami)" to ensure we find the specific item we stored
  key=$(security find-generic-password -a "$(whoami)" -s "$service" -w 2>/dev/null)

  if [[ $? -eq 0 ]]; then
    export "$env_name"="$key"
    echo "✅ Key from '$service' exported as \$$env_name"
  else
    echo "❌ Failed to retrieve key for '$service'"
    return 1
  fi
}

# Delete an API key
delete-api-key() {
  local service="$1"
  [[ -z "$service" ]] && { echo "Usage: delete-api-key <service>"; return 1; }

  security delete-generic-password -a "$(whoami)" -s "$service" 2>/dev/null

  if [[ $? -eq 0 ]]; then
    echo "🗑️  Deleted key for service: $service"
  else
    echo "⚠️  Could not find key to delete for: $service"
  fi
}
