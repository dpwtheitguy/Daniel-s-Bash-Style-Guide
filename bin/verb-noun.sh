#!/usr/bin/env bash
# A simple Hello World script using structured logging and a main function
# SPDX-FileCopyrightText: The Voleon Group
# SPDX-License-Identifier: None
# Daniel Wilson <dwilson@domain.com>
# Data Classification: INTERNAL

set -euo pipefail

# Load logging library
source "$(dirname "${BASH_SOURCE[0]}")/../lib/logging.sh"

function main {
  write-info "Starting Hello World script"
  echo "Hello, World!"
  write-info "Script completed successfully"
}

main "$@"
