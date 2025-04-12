# Daniel's Shell Scripting Style Guide
A style guide for Bash based on Google Style guide. 

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

`
#!/usr/bin/env bash
set -euo pipefail

echo "Hello, ${USER:-unknown user}"
`
