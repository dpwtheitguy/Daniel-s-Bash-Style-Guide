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

```
#!/usr/bin/env bash
set -euo pipefail
```

# When to use Shell? 
Shell should only be used for small utilities or simple wrapper scripts.

While shell scripting isn’t a full-fledged programming language, it is widely used for lightweight tasks and automation. This style guide acknowledges its utility, but does not recommend it for large-scale or complex development.

Security and Supportability Considerations:
Shell scripts are error-prone, hard to test, and lack robust security features like input validation, structured exception handling, and dependency management. For anything beyond very simple tasks, prefer more structured languages like Python or Go, which offer:

Better input handling and type safety

Easier integration with CI/CD pipelines and testing frameworks

Stronger error handling, debugging, and logging

More maintainable and secure codebases over time

Use shell scripts only if:
You're mostly calling other utilities or chaining commands together

The logic is simple, and the script is under 100 lines

There's minimal control flow or conditional logic

Performance is not a primary concern

The script’s lifecycle is short and unlikely to grow in complexity

Avoid shell scripts when:
The script is growing or already exceeds 100 lines

There is non-straightforward control flow

Error handling, data manipulation, or external input processing are required

You want the script to be maintainable by others, or it’s likely to be reused across environments

Tip: Assume your script will grow. Choosing Python or Go early will help avoid costly rewrites, reduce bugs, and improve security from the start.
