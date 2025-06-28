#!/usr/bin/env bash
# Structured, Splunk-friendly logger with optional HEC support
# SPDX-FileCopyrightText: The Voleon Group
# SPDX-License-Identifier: None
# Daniel Wilson <dwilson@voleon.com>
# Data Classification: INTERNAL

# Resolve and load optional config if present
readonly config_path="$(dirname "${BASH_SOURCE[0]}")/../config/config.sh"
if [[ -r "$config_path" ]]; then
  # shellcheck source=../config/config.sh
  source "$config_path"
fi

# LOG_FORMAT options: "kv", "json", "hec"
readonly LOG_FORMAT="${LOG_FORMAT:-kv}"

#######################################
# Logs a structured message.
# Globals:
#   LOG_FORMAT
#   SPLUNK_HEC_TOKEN
#   SPLUNK_HEC_URL
#   SPLUNK_HEC_PORT
# Arguments:
#   $1: log_level (e.g., info, error, debug)
#   $@: message string
# Outputs:
#   STDOUT or STDERR depending on log_level
#######################################
function write-log {
  local log_level="$1"; shift
  readonly log_level

  local message="$*"
  readonly message

  local timestamp
  timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  readonly timestamp

  local script_name="${BASH_SOURCE[1]##*/}"
  readonly script_name

  local pid="$$"
  readonly pid

  local host
  host="$(hostname -f 2>/dev/null || hostname)"
  readonly host

  case "$LOG_FORMAT" in
    kv)
      printf 'time="%s" level="%s" host="%s" script="%s" pid="%s" message="%s"\n' \
        "$timestamp" "$log_level" "$host" "$script_name" "$pid" "$message"
      ;;
    json)
      printf '{ "time": "%s", "level": "%s", "host": "%s", "script": "%s", "pid": "%s", "message": "%s" }\n' \
        "$timestamp" "$log_level" "$host" "$script_name" "$pid" "$message"
      ;;
    hec)
      write-splunkhec "$log_level" "$timestamp" "$host" "$script_name" "$pid" "$message"
      ;;
    *)
      printf 'time="%s" level="error" message="Unsupported LOG_FORMAT: %s"\n' "$timestamp" "$LOG_FORMAT" >&2
      return 1
      ;;
  esac
}

#######################################
# Sends structured log to Splunk HEC endpoint.
# Globals:
#   SPLUNK_HEC_TOKEN
#   SPLUNK_HEC_URL
#   SPLUNK_HEC_PORT
# Arguments:
#   $1: level
#   $2: timestamp
#   $3: host
#   $4: script
#   $5: pid
#   $6: message
#######################################
function write-splunkhec {
  local level="$1"
  readonly level

  local timestamp="$2"
  readonly timestamp

  local host="$3"
  readonly host

  local script="$4"
  readonly script

  local pid="$5"
  readonly pid

  local message="$6"
  readonly message

  if [[ -z "${SPLUNK_HEC_TOKEN:-}" || -z "${SPLUNK_HEC_URL:-}" || -z "${SPLUNK_HEC_PORT:-}" ]]; then
    printf 'time="%s" level="error" message="Missing required HEC config: SPLUNK_HEC_TOKEN, SPLUNK_HEC_URL, SPLUNK_HEC_PORT"\n' "$timestamp" >&2
    return 1
  fi

  local payload
  payload=$(cat <<EOF
{
  "time": "$(date +%s)",
  "host": "$host",
  "source": "$script",
  "event": {
    "level": "$level",
    "script": "$script",
    "pid": "$pid",
    "message": "$message"
  }
}
EOF
)

  curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Splunk $SPLUNK_HEC_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "https://${SPLUNK_HEC_URL}:${SPLUNK_HEC_PORT}/services/collector/event" \
    || printf 'time="%s" level="error" message="Failed to send log to Splunk HEC"\n' "$timestamp" >&2
}

#######################################
# Shortcut: log an info-level message
# Arguments:
#   $@: message
#######################################
function write-info {
  write-log "info" "$@"
}

#######################################
# Shortcut: log a debug-level message
# Arguments:
#   $@: message
#######################################
function write-debug {
  write-log "debug" "$@"
}

#######################################
# Shortcut: log an error-level message to STDERR
# Arguments:
#   $@: message
#######################################
function write-error {
  write-log "error" "$@" >&2
}
