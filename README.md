# Daniel's Shell Scripting Style Guide
A style guide for Bash based on Google Style guide. 

## The "meh" of Shell Scripting
1. Readability counts, even in Bash.
2. Explicit is better than implicit — flag your assumptions.
3. Simplicity beats cleverness, especially in production.
4. Errors should never pass silently (unless explicitly handled).
5. Shellcheck is your friend.
6. Logging beats echoing. Use STDERR or syslog, not guesswork.
7. There should be one obvious way to do it — pick Bash, stick to it.
8. Avoid side effects and subshell surprises.
9. Scripts should fail loudly and early. `set -euo pipefail` is a must.
10. Don't parse output you can't control.
11. Temporary files are liabilities — clean up after yourself.
12. Test your scripts with shellcheck and in CI before deployment.
13. Avoid magic. Future maintainers will thank you.
14. Naming matters — no more `x`, `tmp`, or `foo`.
15. Prefer functions over long procedural blobs.
16. Secure by default — never trust `$1`.
17. Comments are better than cryptic Bash-fu.
18. Don’t reinvent package managers. If you need real logic, use Python.
19. No script should grow beyond what Bash was meant to handle.
20. When in doubt, break it into smaller scripts — or switch languages.

## Background
Bash is the only shell scripting language permitted for executables.

All executable shell scripts must start with a shebang line using the /usr/bin/env pattern:

`#!/usr/bin/env bash`

This ensures the script uses the bash interpreter found in the user's PATH, increasing portability across environments where bash may not be located at /bin/bash.

Use minimal flags in the shebang. Instead, configure script behavior using set within the script body. This ensures consistent behavior even if the script is run manually using bash script.sh.

Recommended set flags
Include these at the top of your script:
`set -euo pipefail`
Explanation:

-e: Exit immediately if any command exits with a non-zero status.

-u: Treat unset variables as an error and exit.

-o pipefail: Return the exit code of the last command in the pipeline that failed, rather than the last command overall.

This combination helps catch bugs early and prevents unpredictable script behavior.

```
#!/usr/bin/env bash
set -euo pipefail
```

# When to use Shell? 
Shell should only be used for small utilities or simple wrapper scripts.

While shell scripting isn’t a full-fledged programming language, it is widely used for lightweight tasks and automation. This style guide acknowledges its utility, but does not recommend it for large-scale or complex development.

Security and Supportability Considerations:
1. Shell scripts are error-prone, hard to test, and lack robust security features like input validation, structured exception handling, and dependency management. For anything beyond very simple tasks, prefer more structured languages like Python or Go, which offer:
2. Better input handling and type safety
3. Easier integration with CI/CD pipelines and testing frameworks
4. Stronger error handling, debugging, and logging
5. More maintainable and secure codebases over time

Use shell scripts only if:
1. You're mostly calling other utilities or chaining commands together
2. The logic is simple, and the script is under ~200 lines
3. There's minimal control flow or conditional logic
4. Performance is not a primary concern
5. The script’s lifecycle is short and unlikely to grow in complexity

Avoid shell scripts when:
1. The script is growing or already exceeds 100 lines
2. There is non-straightforward control flow
3. Error handling, data manipulation, or external input processing are required
4. You want the script to be maintainable by others, or it’s likely to be reused across environments

Tip: 
Assume your script will grow. Choosing Python or Go early will help avoid costly rewrites, reduce bugs, and improve security from the start.

# Shell Files and Interpreter Invocation
Shell script executables should have either a .sh extension or no extension, depending on how they’re used. Scripts should check their filename at runtime if needed.

Use .sh extension when:
1. The script is a source file involved in a build process and the output will be renamed by a build rule.
Example: foo.sh as the source and a build rule generating foo.

This makes it easier to apply consistent naming conventions and track source files in version control.

2. Use no extension when:
The script is an end-user-facing command added directly to the user’s PATH.
``` bash
Example: /usr/local/bin/deploy
```

Users shouldn’t need to know the implementation language; shell does not require an extension to execute.

If neither case applies:
Either choice is acceptable, but be consistent within your project.

Script Location for Executables
For larger or more complex scripts, place the executable shell wrapper in /bin, and organize supporting libraries and logic separately to improve maintainability.

Shell Libraries
Shell libraries must have a .sh extension. 
Libraries should not be executable.
Store libraries in the /lib directory (or your team’s standardized equivalent).

# SUID/SGID
SUID and SGID are strictly forbidden on shell scripts and must be explicitly checked for at runtime if applicable.

There are too many security issues with shell that make it nearly impossible to secure sufficiently to allow SUID/SGID. While bash does make it difficult to run SUID, it’s still possible on some platforms which is why we’re being explicit about banning it.

Use sudo to provide elevated access if you need it.


```bash
validate_scriptsec() {
  local script_path="$1"

  # Constants
  local SUID_FLAG_PATTERN="s"
  local VALID_EXTENSION=".sh"
  local INSECURE_DIRS=("/tmp" "/var/tmp" "/dev/shm")

  if [[ ! -f "$script_path" ]]; then
    printf "❌ Error: '%s' does not exist or is not a regular file.\n" "$script_path" >&2
    return 1
  fi

  local file_name
  file_name="$(basename "$script_path")"

  # Extension check
  if [[ "$file_name" == *.* && "$file_name" != *"$VALID_EXTENSION" ]]; then
    printf "❌ Error: '%s' must have either no extension or a '%s' extension.\n" "$file_name" "$VALID_EXTENSION" >&2
    return 1
  fi

  # Insecure directory check
  local script_dir
  script_dir="$(dirname "$(readlink -f "$script_path")")"
  for insecure_dir in "${INSECURE_DIRS[@]}"; do
    if [[ "$script_dir" == "$insecure_dir"* ]]; then
      printf "❌ Error: '%s' is located in insecure directory '%s'.\n" "$file_name" "$insecure_dir" >&2
      return 1
    fi
  done

  # Permission bits
  local permissions permission_string
  permissions=$(stat -c "%a %A" "$script_path")
  read -r permission_value permission_string <<< "$permissions"

  # SUID/SGID check
  if [[ "$permission_string" =~ $SUID_FLAG_PATTERN ]]; then
    printf "❌ Error: '%s' must not have SUID or SGID bits set.\n" "$file_name" >&2
    return 1
  fi

  # Too-permissive permissions
  if [[ "$permission_value" =~ ^[0-7]*[2367]$ ]]; then
    printf "❌ Error: '%s' has world-writable or group-writable permissions (%s).\n" "$file_name" "$permission_value" >&2
    return 1
  fi

  printf "✅ '%s' passed security checks.\n" "$file_name"
  return 0
}
```

# Environment

STDOUT vs STDERR
All error messages **must go to STDERR**. This separation makes it easier to distinguish between expected output and actual issues, and supports robust scripting, automation, and alerting pipelines.

Here is an example err function you might include directly or as a library.
```bash
err() {
  local message="$*"
  local timestamp
  timestamp="$(date +'%Y-%m-%dT%H:%M:%S%z')"
  local user
  user="$(whoami)"
  local script_name
  script_name="$(basename "$0")"

  # Print to STDERR
  printf "%s error event=script_error user=%s script=%s message=%q\n" \
    "$timestamp" "$user" "$script_name" "$message" >&2

  # Send to system log (useful in cron, ephemeral containers, etc.)
  logger -t "$script_name" \
    "event=script_error user=$user script=$script_name message=$(printf "%q" "$message")"
}
```

# Comments
File Header
Start each file with a description of its contents, Authoir, License, Data classification, Intellectual Property tracker and version data. These fields must be filled out for documentation generation automation. 

Free form documentation may exist below the Version data and it's highly recommended that this include ASCII diagrams and debugging notes. If the free form documentation gets too extensive move it's contents to the README.md

```
#!/usr/bin/env bash
#
# ==============================================================================
# File Header
# ==============================================================================
# Description     : Perform hot backups of Oracle databases
# Author          : user.name <user.name@email.domain>
# SPDX-License-Identifier: MIT
# Data Classification: Internal/Confidential/Restricted (Specify classification)
# Intellectual Property Tracker: IP-12345 (Specify your internal IP tracker or identifier)
# Version         : 1.0.0
# Created         : 2025-04-12
# Last Modified   : 2025-04-12
#
# ==============================================================================
# Free Form Notes:
# ==============================================================================
# - Ensure Oracle database is running before initiating the backup
# - This script can be configured to email completion notifications
# - Requires Oracle Backup user with appropriate permissions
#
# ASCII Diagrams or Debugging Notes:
# ==============================================================================
# [INSERT ASCII DIAGRAMS OR DEBUGGING STEPS BELOW IF NECESSARY]
# E.g., 
#   +---------------------------+
#   |     Oracle Hot Backup     |
#   +---------------------------+
#   |   Start > Database Online |
#   +---------------------------+
#
# If the free form documentation becomes too extensive, move its contents
# to a README.md file and provide a link in the file.
# ==============================================================================

```
