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
