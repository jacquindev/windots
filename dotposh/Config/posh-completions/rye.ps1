using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'rye' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'rye'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
            }
            $element.Value
        }) -join ';'

    $completions = @(switch ($command) {
            'rye' {
                [CompletionResult]::new('--env-file', '--env-file', [CompletionResultType]::ParameterName, 'Load one or more .env files')
                [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print the version')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Adds a Python package to this project')
                [CompletionResult]::new('build', 'build', [CompletionResultType]::ParameterValue, 'Builds a package for distribution')
                [CompletionResult]::new('config', 'config', [CompletionResultType]::ParameterValue, 'Reads or modifies the global `config.toml` file')
                [CompletionResult]::new('fetch', 'fetch', [CompletionResultType]::ParameterValue, 'Fetches a Python interpreter for the local machine')
                [CompletionResult]::new('fmt', 'fmt', [CompletionResultType]::ParameterValue, 'Run the code formatter on the project')
                [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Initialize a new or existing Python project with Rye')
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Installs a package as global tool')
                [CompletionResult]::new('lock', 'lock', [CompletionResultType]::ParameterValue, 'Updates the lockfiles without installing dependencies')
                [CompletionResult]::new('lint', 'lint', [CompletionResultType]::ParameterValue, 'Run the linter on the project')
                [CompletionResult]::new('make-req', 'make-req', [CompletionResultType]::ParameterValue, 'Builds and prints a PEP 508 requirement string from parts')
                [CompletionResult]::new('pin', 'pin', [CompletionResultType]::ParameterValue, 'Pins a Python version to this project')
                [CompletionResult]::new('publish', 'publish', [CompletionResultType]::ParameterValue, 'Publish packages to a package repository')
                [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Removes a package from this project')
                [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Runs a command installed into this package')
                [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Prints the current state of the project')
                [CompletionResult]::new('sync', 'sync', [CompletionResultType]::ParameterValue, 'Updates the virtualenv based on the pyproject.toml')
                [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Run the tests on the project')
                [CompletionResult]::new('toolchain', 'toolchain', [CompletionResultType]::ParameterValue, 'Helper utility to manage Python toolchains')
                [CompletionResult]::new('tools', 'tools', [CompletionResultType]::ParameterValue, 'Helper utility to manage global tools')
                [CompletionResult]::new('self', 'self', [CompletionResultType]::ParameterValue, 'Rye self management')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls a global tool')
                [CompletionResult]::new('version', 'version', [CompletionResultType]::ParameterValue, 'Get or set project version')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'Prints the currently installed packages')
                [CompletionResult]::new('shell', 'shell', [CompletionResultType]::ParameterValue, 'The shell command was removed')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;add' {
                [CompletionResult]::new('--git', '--git', [CompletionResultType]::ParameterName, 'Install the given package from this git repository')
                [CompletionResult]::new('--url', '--url', [CompletionResultType]::ParameterName, 'Install the given package from this URL')
                [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Install the given package from this local path')
                [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Install a specific tag')
                [CompletionResult]::new('--rev', '--rev', [CompletionResultType]::ParameterName, 'Update to a specific git rev')
                [CompletionResult]::new('--branch', '--branch', [CompletionResultType]::ParameterName, 'Update to a specific git branch')
                [CompletionResult]::new('--features', '--features', [CompletionResultType]::ParameterName, 'Adds a dependency with a specific feature')
                [CompletionResult]::new('--optional', '--optional', [CompletionResultType]::ParameterName, 'Add this to an optional dependency group')
                [CompletionResult]::new('--pin', '--pin', [CompletionResultType]::ParameterName, 'Overrides the pin operator')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('--absolute', '--absolute', [CompletionResultType]::ParameterName, 'Force non interpolated absolute paths')
                [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Add this as dev dependency')
                [CompletionResult]::new('--dev', '--dev', [CompletionResultType]::ParameterName, 'Add this as dev dependency')
                [CompletionResult]::new('--excluded', '--excluded', [CompletionResultType]::ParameterName, 'Add this as an excluded dependency that will not be installed even if it''s a sub dependency')
                [CompletionResult]::new('--sync', '--sync', [CompletionResultType]::ParameterName, 'Runs `sync` even if auto-sync is disabled')
                [CompletionResult]::new('--no-sync', '--no-sync', [CompletionResultType]::ParameterName, 'Does not run `sync` even if auto-sync is enabled')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--pre', '--pre', [CompletionResultType]::ParameterName, 'Include pre-releases when finding a package version and automatically syncing the workspace')
                [CompletionResult]::new('--with-sources', '--with-sources', [CompletionResultType]::ParameterName, 'Set to `true` to lock with sources in the lockfile when automatically syncing the workspace')
                [CompletionResult]::new('--generate-hashes', '--generate-hashes', [CompletionResultType]::ParameterName, 'Set to `true` to lock with hashes in the lockfile when automatically syncing the workspace')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;build' {
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Build a specific package')
                [CompletionResult]::new('--package', '--package', [CompletionResultType]::ParameterName, 'Build a specific package')
                [CompletionResult]::new('-o', '-o', [CompletionResultType]::ParameterName, 'An output directory (defaults to `workspace/dist`)')
                [CompletionResult]::new('--out', '--out', [CompletionResultType]::ParameterName, 'An output directory (defaults to `workspace/dist`)')
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('--sdist', '--sdist', [CompletionResultType]::ParameterName, 'Build a sdist')
                [CompletionResult]::new('--wheel', '--wheel', [CompletionResultType]::ParameterName, 'Build a wheel')
                [CompletionResult]::new('-a', '-a', [CompletionResultType]::ParameterName, 'Build all packages')
                [CompletionResult]::new('--all', '--all', [CompletionResultType]::ParameterName, 'Build all packages')
                [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Clean the output directory first')
                [CompletionResult]::new('--clean', '--clean', [CompletionResultType]::ParameterName, 'Clean the output directory first')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;config' {
                [CompletionResult]::new('--format', '--format', [CompletionResultType]::ParameterName, 'Request parseable output format rather than lines')
                [CompletionResult]::new('--get', '--get', [CompletionResultType]::ParameterName, 'Reads a config key')
                [CompletionResult]::new('--set', '--set', [CompletionResultType]::ParameterName, 'Sets a config key to a string')
                [CompletionResult]::new('--set-int', '--set-int', [CompletionResultType]::ParameterName, 'Sets a config key to an integer')
                [CompletionResult]::new('--set-bool', '--set-bool', [CompletionResultType]::ParameterName, 'Sets a config key to a bool')
                [CompletionResult]::new('--unset', '--unset', [CompletionResultType]::ParameterName, 'Remove a config key')
                [CompletionResult]::new('--show-path', '--show-path', [CompletionResultType]::ParameterName, 'Print the path to the config')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;fetch' {
                [CompletionResult]::new('--target-path', '--target-path', [CompletionResultType]::ParameterName, 'Fetches the Python toolchain into an explicit location rather')
                [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Fetch the Python toolchain even if it is already installed')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Fetch the Python toolchain even if it is already installed')
                [CompletionResult]::new('--build-info', '--build-info', [CompletionResultType]::ParameterName, 'Fetches with build info')
                [CompletionResult]::new('--no-build-info', '--no-build-info', [CompletionResultType]::ParameterName, 'Fetches without build info')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;fmt' {
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Perform the operation on a specific package')
                [CompletionResult]::new('--package', '--package', [CompletionResultType]::ParameterName, 'Perform the operation on a specific package')
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('-a', '-a', [CompletionResultType]::ParameterName, 'Perform the operation on all packages')
                [CompletionResult]::new('--all', '--all', [CompletionResultType]::ParameterName, 'Perform the operation on all packages')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--check', '--check', [CompletionResultType]::ParameterName, 'Run format in check mode')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;init' {
                [CompletionResult]::new('--min-py', '--min-py', [CompletionResultType]::ParameterName, 'Minimal Python version supported by this project')
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Python version to use for the virtualenv')
                [CompletionResult]::new('--py', '--py', [CompletionResultType]::ParameterName, 'Python version to use for the virtualenv')
                [CompletionResult]::new('--build-system', '--build-system', [CompletionResultType]::ParameterName, 'Which build system should be used (defaults to hatchling)?')
                [CompletionResult]::new('--license', '--license', [CompletionResultType]::ParameterName, 'Which license should be used (SPDX identifier)?')
                [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'The name of the package')
                [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Requirements files to initialize pyproject.toml with')
                [CompletionResult]::new('--requirements', '--requirements', [CompletionResultType]::ParameterName, 'Requirements files to initialize pyproject.toml with')
                [CompletionResult]::new('--dev-requirements', '--dev-requirements', [CompletionResultType]::ParameterName, 'Development requirements files to initialize pyproject.toml with')
                [CompletionResult]::new('--lib', '--lib', [CompletionResultType]::ParameterName, 'Generate a library project (default)')
                [CompletionResult]::new('--script', '--script', [CompletionResultType]::ParameterName, 'Generate an executable project')
                [CompletionResult]::new('--no-readme', '--no-readme', [CompletionResultType]::ParameterName, 'Do not create a readme')
                [CompletionResult]::new('--no-pin', '--no-pin', [CompletionResultType]::ParameterName, 'Do not create .python-version file (requires-python will be used)')
                [CompletionResult]::new('--private', '--private', [CompletionResultType]::ParameterName, 'Set "Private :: Do Not Upload" classifier, used for private projects')
                [CompletionResult]::new('--no-import', '--no-import', [CompletionResultType]::ParameterName, 'Don''t import from setup.cfg, setup.py, or requirements files')
                [CompletionResult]::new('--virtual', '--virtual', [CompletionResultType]::ParameterName, 'Initialize this as a virtual package')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;install' {
                [CompletionResult]::new('--git', '--git', [CompletionResultType]::ParameterName, 'Install the given package from this git repository')
                [CompletionResult]::new('--url', '--url', [CompletionResultType]::ParameterName, 'Install the given package from this URL')
                [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Install the given package from this local path')
                [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Install a specific tag')
                [CompletionResult]::new('--rev', '--rev', [CompletionResultType]::ParameterName, 'Update to a specific git rev')
                [CompletionResult]::new('--branch', '--branch', [CompletionResultType]::ParameterName, 'Update to a specific git branch')
                [CompletionResult]::new('--features', '--features', [CompletionResultType]::ParameterName, 'Adds a dependency with a specific feature')
                [CompletionResult]::new('--include-dep', '--include-dep', [CompletionResultType]::ParameterName, 'Include scripts from a given dependency')
                [CompletionResult]::new('--extra-requirement', '--extra-requirement', [CompletionResultType]::ParameterName, 'Additional dependencies to install that are not declared by the main package')
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Optionally the Python version to use')
                [CompletionResult]::new('--python', '--python', [CompletionResultType]::ParameterName, 'Optionally the Python version to use')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('--absolute', '--absolute', [CompletionResultType]::ParameterName, 'Force non interpolated absolute paths')
                [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force install the package even if it''s already there')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force install the package even if it''s already there')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;lock' {
                [CompletionResult]::new('--update', '--update', [CompletionResultType]::ParameterName, 'Update a specific package')
                [CompletionResult]::new('--features', '--features', [CompletionResultType]::ParameterName, 'Extras/features to enable when locking the workspace')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--update-all', '--update-all', [CompletionResultType]::ParameterName, 'Update all packages to the latest')
                [CompletionResult]::new('--pre', '--pre', [CompletionResultType]::ParameterName, 'Update to pre-release versions')
                [CompletionResult]::new('--all-features', '--all-features', [CompletionResultType]::ParameterName, 'Enables all features')
                [CompletionResult]::new('--with-sources', '--with-sources', [CompletionResultType]::ParameterName, 'Set to true to lock with sources in the lockfile')
                [CompletionResult]::new('--generate-hashes', '--generate-hashes', [CompletionResultType]::ParameterName, 'Set to true to lock with hashes in the lockfile')
                [CompletionResult]::new('--universal', '--universal', [CompletionResultType]::ParameterName, 'Use universal lock files')
                [CompletionResult]::new('--reset', '--reset', [CompletionResultType]::ParameterName, 'Reset prior lock options')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;lint' {
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Perform the operation on a specific package')
                [CompletionResult]::new('--package', '--package', [CompletionResultType]::ParameterName, 'Perform the operation on a specific package')
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('-a', '-a', [CompletionResultType]::ParameterName, 'Perform the operation on all packages')
                [CompletionResult]::new('--all', '--all', [CompletionResultType]::ParameterName, 'Perform the operation on all packages')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--fix', '--fix', [CompletionResultType]::ParameterName, 'Apply fixes')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;make-req' {
                [CompletionResult]::new('--git', '--git', [CompletionResultType]::ParameterName, 'Install the given package from this git repository')
                [CompletionResult]::new('--url', '--url', [CompletionResultType]::ParameterName, 'Install the given package from this URL')
                [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Install the given package from this local path')
                [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Install a specific tag')
                [CompletionResult]::new('--rev', '--rev', [CompletionResultType]::ParameterName, 'Update to a specific git rev')
                [CompletionResult]::new('--branch', '--branch', [CompletionResultType]::ParameterName, 'Update to a specific git branch')
                [CompletionResult]::new('--features', '--features', [CompletionResultType]::ParameterName, 'Adds a dependency with a specific feature')
                [CompletionResult]::new('--absolute', '--absolute', [CompletionResultType]::ParameterName, 'Force non interpolated absolute paths')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;pin' {
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('--relaxed', '--relaxed', [CompletionResultType]::ParameterName, 'Issue a relaxed pin')
                [CompletionResult]::new('--no-update-requires-python', '--no-update-requires-python', [CompletionResultType]::ParameterName, 'Prevent updating requires-python in the pyproject.toml')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;publish' {
                [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'The repository to publish to')
                [CompletionResult]::new('--repository', '--repository', [CompletionResultType]::ParameterName, 'The repository to publish to')
                [CompletionResult]::new('--repository-url', '--repository-url', [CompletionResultType]::ParameterName, 'The repository url to publish to')
                [CompletionResult]::new('-u', '-u', [CompletionResultType]::ParameterName, 'The username to authenticate to the repository with')
                [CompletionResult]::new('--username', '--username', [CompletionResultType]::ParameterName, 'The username to authenticate to the repository with')
                [CompletionResult]::new('--token', '--token', [CompletionResultType]::ParameterName, 'An access token used for the upload')
                [CompletionResult]::new('-i', '-i', [CompletionResultType]::ParameterName, 'GPG identity used to sign files')
                [CompletionResult]::new('--identity', '--identity', [CompletionResultType]::ParameterName, 'GPG identity used to sign files')
                [CompletionResult]::new('--cert', '--cert', [CompletionResultType]::ParameterName, 'Path to alternate CA bundle')
                [CompletionResult]::new('--sign', '--sign', [CompletionResultType]::ParameterName, 'Sign files to upload using GPG')
                [CompletionResult]::new('--skip-existing', '--skip-existing', [CompletionResultType]::ParameterName, 'Skip files that have already been published (only applies to repositories supporting this feature)')
                [CompletionResult]::new('-y', '-y', [CompletionResultType]::ParameterName, 'Skip prompts')
                [CompletionResult]::new('--yes', '--yes', [CompletionResultType]::ParameterName, 'Skip prompts')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;remove' {
                [CompletionResult]::new('--optional', '--optional', [CompletionResultType]::ParameterName, 'Remove this from an optional dependency group')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Remove this from dev dependencies')
                [CompletionResult]::new('--dev', '--dev', [CompletionResultType]::ParameterName, 'Remove this from dev dependencies')
                [CompletionResult]::new('--sync', '--sync', [CompletionResultType]::ParameterName, 'Runs `sync` even if auto-sync is disabled')
                [CompletionResult]::new('--no-sync', '--no-sync', [CompletionResultType]::ParameterName, 'Does not run `sync` even if auto-sync is enabled')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--pre', '--pre', [CompletionResultType]::ParameterName, 'Include pre-releases when automatically syncing the workspace')
                [CompletionResult]::new('--with-sources', '--with-sources', [CompletionResultType]::ParameterName, 'Set to `true` to lock with sources in the lockfile when automatically syncing the workspace')
                [CompletionResult]::new('--generate-hashes', '--generate-hashes', [CompletionResultType]::ParameterName, 'Set to `true` to lock with hashes in the lockfile when automatically syncing the workspace')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;run' {
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('-l', '-l', [CompletionResultType]::ParameterName, 'List all commands')
                [CompletionResult]::new('--list', '--list', [CompletionResultType]::ParameterName, 'List all commands')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;show' {
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('--installed-deps', '--installed-deps', [CompletionResultType]::ParameterName, 'Print the installed dependencies from the venv')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;sync' {
                [CompletionResult]::new('--update', '--update', [CompletionResultType]::ParameterName, 'Update a specific package')
                [CompletionResult]::new('--features', '--features', [CompletionResultType]::ParameterName, 'Extras/features to enable when syncing the workspace')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force the environment to be re-created')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force the environment to be re-created')
                [CompletionResult]::new('--no-dev', '--no-dev', [CompletionResultType]::ParameterName, 'Do not include dev dependencies')
                [CompletionResult]::new('--no-lock', '--no-lock', [CompletionResultType]::ParameterName, 'Do not update the lockfile')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--update-all', '--update-all', [CompletionResultType]::ParameterName, 'Update all packages to the latest')
                [CompletionResult]::new('--pre', '--pre', [CompletionResultType]::ParameterName, 'Update to pre-release versions')
                [CompletionResult]::new('--all-features', '--all-features', [CompletionResultType]::ParameterName, 'Enables all features')
                [CompletionResult]::new('--with-sources', '--with-sources', [CompletionResultType]::ParameterName, 'Set to true to lock with sources in the lockfile')
                [CompletionResult]::new('--generate-hashes', '--generate-hashes', [CompletionResultType]::ParameterName, 'Set to true to lock with hashes in the lockfile')
                [CompletionResult]::new('--reset', '--reset', [CompletionResultType]::ParameterName, 'Do not reuse (reset) prior lock options')
                [CompletionResult]::new('--universal', '--universal', [CompletionResultType]::ParameterName, 'Use universal lock files')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;test' {
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Perform the operation on a specific package')
                [CompletionResult]::new('--package', '--package', [CompletionResultType]::ParameterName, 'Perform the operation on a specific package')
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('-a', '-a', [CompletionResultType]::ParameterName, 'Perform the operation on all packages')
                [CompletionResult]::new('--all', '--all', [CompletionResultType]::ParameterName, 'Perform the operation on all packages')
                [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Disable test output capture to stdout')
                [CompletionResult]::new('--no-capture', '--no-capture', [CompletionResultType]::ParameterName, 'Disable test output capture to stdout')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--pre', '--pre', [CompletionResultType]::ParameterName, 'Include pre-releases when automatically syncing the workspace')
                [CompletionResult]::new('--with-sources', '--with-sources', [CompletionResultType]::ParameterName, 'Set to `true` to lock with sources in the lockfile when automatically syncing the workspace')
                [CompletionResult]::new('--generate-hashes', '--generate-hashes', [CompletionResultType]::ParameterName, 'Set to `true` to lock with hashes in the lockfile when automatically syncing the workspace')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;toolchain' {
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('fetch', 'fetch', [CompletionResultType]::ParameterValue, 'Fetches a Python interpreter for the local machine')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all registered toolchains')
                [CompletionResult]::new('register', 'register', [CompletionResultType]::ParameterValue, 'Register a Python binary')
                [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Removes a toolchain')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;toolchain;fetch' {
                [CompletionResult]::new('--target-path', '--target-path', [CompletionResultType]::ParameterName, 'Fetches the Python toolchain into an explicit location rather')
                [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Fetch the Python toolchain even if it is already installed')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Fetch the Python toolchain even if it is already installed')
                [CompletionResult]::new('--build-info', '--build-info', [CompletionResultType]::ParameterName, 'Fetches with build info')
                [CompletionResult]::new('--no-build-info', '--no-build-info', [CompletionResultType]::ParameterName, 'Fetches without build info')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;toolchain;list' {
                [CompletionResult]::new('--format', '--format', [CompletionResultType]::ParameterName, 'Request parseable output format')
                [CompletionResult]::new('--include-downloadable', '--include-downloadable', [CompletionResultType]::ParameterName, 'Also include non installed, but downloadable toolchains')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;toolchain;register' {
                [CompletionResult]::new('-n', '-n', [CompletionResultType]::ParameterName, 'Name of the toolchain.  If not provided a name is auto detected')
                [CompletionResult]::new('--name', '--name', [CompletionResultType]::ParameterName, 'Name of the toolchain.  If not provided a name is auto detected')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;toolchain;remove' {
                [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force removal even if the toolchain is in use')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force removal even if the toolchain is in use')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;toolchain;help' {
                [CompletionResult]::new('fetch', 'fetch', [CompletionResultType]::ParameterValue, 'Fetches a Python interpreter for the local machine')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all registered toolchains')
                [CompletionResult]::new('register', 'register', [CompletionResultType]::ParameterValue, 'Register a Python binary')
                [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Removes a toolchain')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;toolchain;help;fetch' {
                break
            }
            'rye;toolchain;help;list' {
                break
            }
            'rye;toolchain;help;register' {
                break
            }
            'rye;toolchain;help;remove' {
                break
            }
            'rye;toolchain;help;help' {
                break
            }
            'rye;tools' {
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Installs a package as global tool')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls a global tool')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all registered tools')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;tools;install' {
                [CompletionResult]::new('--git', '--git', [CompletionResultType]::ParameterName, 'Install the given package from this git repository')
                [CompletionResult]::new('--url', '--url', [CompletionResultType]::ParameterName, 'Install the given package from this URL')
                [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Install the given package from this local path')
                [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Install a specific tag')
                [CompletionResult]::new('--rev', '--rev', [CompletionResultType]::ParameterName, 'Update to a specific git rev')
                [CompletionResult]::new('--branch', '--branch', [CompletionResultType]::ParameterName, 'Update to a specific git branch')
                [CompletionResult]::new('--features', '--features', [CompletionResultType]::ParameterName, 'Adds a dependency with a specific feature')
                [CompletionResult]::new('--include-dep', '--include-dep', [CompletionResultType]::ParameterName, 'Include scripts from a given dependency')
                [CompletionResult]::new('--extra-requirement', '--extra-requirement', [CompletionResultType]::ParameterName, 'Additional dependencies to install that are not declared by the main package')
                [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Optionally the Python version to use')
                [CompletionResult]::new('--python', '--python', [CompletionResultType]::ParameterName, 'Optionally the Python version to use')
                [CompletionResult]::new('--keyring-provider', '--keyring-provider', [CompletionResultType]::ParameterName, 'Attempt to use `keyring` for authentication for index URLs')
                [CompletionResult]::new('--absolute', '--absolute', [CompletionResultType]::ParameterName, 'Force non interpolated absolute paths')
                [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force install the package even if it''s already there')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force install the package even if it''s already there')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;tools;uninstall' {
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;tools;list' {
                [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Show all the scripts installed by the tools')
                [CompletionResult]::new('--include-scripts', '--include-scripts', [CompletionResultType]::ParameterName, 'Show all the scripts installed by the tools')
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Show the version of tools')
                [CompletionResult]::new('--include-version', '--include-version', [CompletionResultType]::ParameterName, 'Show the version of tools')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;tools;help' {
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Installs a package as global tool')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls a global tool')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all registered tools')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;tools;help;install' {
                break
            }
            'rye;tools;help;uninstall' {
                break
            }
            'rye;tools;help;list' {
                break
            }
            'rye;tools;help;help' {
                break
            }
            'rye;self' {
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('completion', 'completion', [CompletionResultType]::ParameterValue, 'Generates a completion script for a shell')
                [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Performs an update of rye')
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Triggers the initial installation of Rye')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls rye again')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;self;completion' {
                [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'The shell to generate a completion script for (defaults to ''bash'')')
                [CompletionResult]::new('--shell', '--shell', [CompletionResultType]::ParameterName, 'The shell to generate a completion script for (defaults to ''bash'')')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;self;update' {
                [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Update to a specific version')
                [CompletionResult]::new('--tag', '--tag', [CompletionResultType]::ParameterName, 'Update to a specific tag')
                [CompletionResult]::new('--rev', '--rev', [CompletionResultType]::ParameterName, 'Update to a specific git rev')
                [CompletionResult]::new('--branch', '--branch', [CompletionResultType]::ParameterName, 'Update to a specific git branch')
                [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force reinstallation')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;self;install' {
                [CompletionResult]::new('--toolchain', '--toolchain', [CompletionResultType]::ParameterName, 'Register a specific toolchain before bootstrap')
                [CompletionResult]::new('--toolchain-version', '--toolchain-version', [CompletionResultType]::ParameterName, 'Use a specific toolchain version')
                [CompletionResult]::new('-y', '-y', [CompletionResultType]::ParameterName, 'Skip prompts')
                [CompletionResult]::new('--yes', '--yes', [CompletionResultType]::ParameterName, 'Skip prompts')
                [CompletionResult]::new('--modify-path', '--modify-path', [CompletionResultType]::ParameterName, 'Always modify without asking the PATH environment variable')
                [CompletionResult]::new('--no-modify-path', '--no-modify-path', [CompletionResultType]::ParameterName, 'Do not modify the PATH environment variable')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
                break
            }
            'rye;self;uninstall' {
                [CompletionResult]::new('-y', '-y', [CompletionResultType]::ParameterName, 'Skip safety check')
                [CompletionResult]::new('--yes', '--yes', [CompletionResultType]::ParameterName, 'Skip safety check')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;self;help' {
                [CompletionResult]::new('completion', 'completion', [CompletionResultType]::ParameterValue, 'Generates a completion script for a shell')
                [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Performs an update of rye')
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Triggers the initial installation of Rye')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls rye again')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;self;help;completion' {
                break
            }
            'rye;self;help;update' {
                break
            }
            'rye;self;help;install' {
                break
            }
            'rye;self;help;uninstall' {
                break
            }
            'rye;self;help;help' {
                break
            }
            'rye;uninstall' {
                [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('--verbose', '--verbose', [CompletionResultType]::ParameterName, 'Enables verbose diagnostics')
                [CompletionResult]::new('-q', '-q', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('--quiet', '--quiet', [CompletionResultType]::ParameterName, 'Turns off all output')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;version' {
                [CompletionResult]::new('-b', '-b', [CompletionResultType]::ParameterName, 'The version bump to apply')
                [CompletionResult]::new('--bump', '--bump', [CompletionResultType]::ParameterName, 'The version bump to apply')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;list' {
                [CompletionResult]::new('--pyproject', '--pyproject', [CompletionResultType]::ParameterName, 'Use this pyproject.toml file')
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;shell' {
                [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
                [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
                break
            }
            'rye;help' {
                [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Adds a Python package to this project')
                [CompletionResult]::new('build', 'build', [CompletionResultType]::ParameterValue, 'Builds a package for distribution')
                [CompletionResult]::new('config', 'config', [CompletionResultType]::ParameterValue, 'Reads or modifies the global `config.toml` file')
                [CompletionResult]::new('fetch', 'fetch', [CompletionResultType]::ParameterValue, 'Fetches a Python interpreter for the local machine')
                [CompletionResult]::new('fmt', 'fmt', [CompletionResultType]::ParameterValue, 'Run the code formatter on the project')
                [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Initialize a new or existing Python project with Rye')
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Installs a package as global tool')
                [CompletionResult]::new('lock', 'lock', [CompletionResultType]::ParameterValue, 'Updates the lockfiles without installing dependencies')
                [CompletionResult]::new('lint', 'lint', [CompletionResultType]::ParameterValue, 'Run the linter on the project')
                [CompletionResult]::new('make-req', 'make-req', [CompletionResultType]::ParameterValue, 'Builds and prints a PEP 508 requirement string from parts')
                [CompletionResult]::new('pin', 'pin', [CompletionResultType]::ParameterValue, 'Pins a Python version to this project')
                [CompletionResult]::new('publish', 'publish', [CompletionResultType]::ParameterValue, 'Publish packages to a package repository')
                [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Removes a package from this project')
                [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Runs a command installed into this package')
                [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Prints the current state of the project')
                [CompletionResult]::new('sync', 'sync', [CompletionResultType]::ParameterValue, 'Updates the virtualenv based on the pyproject.toml')
                [CompletionResult]::new('test', 'test', [CompletionResultType]::ParameterValue, 'Run the tests on the project')
                [CompletionResult]::new('toolchain', 'toolchain', [CompletionResultType]::ParameterValue, 'Helper utility to manage Python toolchains')
                [CompletionResult]::new('tools', 'tools', [CompletionResultType]::ParameterValue, 'Helper utility to manage global tools')
                [CompletionResult]::new('self', 'self', [CompletionResultType]::ParameterValue, 'Rye self management')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls a global tool')
                [CompletionResult]::new('version', 'version', [CompletionResultType]::ParameterValue, 'Get or set project version')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'Prints the currently installed packages')
                [CompletionResult]::new('shell', 'shell', [CompletionResultType]::ParameterValue, 'The shell command was removed')
                [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
                break
            }
            'rye;help;add' {
                break
            }
            'rye;help;build' {
                break
            }
            'rye;help;config' {
                break
            }
            'rye;help;fetch' {
                break
            }
            'rye;help;fmt' {
                break
            }
            'rye;help;init' {
                break
            }
            'rye;help;install' {
                break
            }
            'rye;help;lock' {
                break
            }
            'rye;help;lint' {
                break
            }
            'rye;help;make-req' {
                break
            }
            'rye;help;pin' {
                break
            }
            'rye;help;publish' {
                break
            }
            'rye;help;remove' {
                break
            }
            'rye;help;run' {
                break
            }
            'rye;help;show' {
                break
            }
            'rye;help;sync' {
                break
            }
            'rye;help;test' {
                break
            }
            'rye;help;toolchain' {
                [CompletionResult]::new('fetch', 'fetch', [CompletionResultType]::ParameterValue, 'Fetches a Python interpreter for the local machine')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all registered toolchains')
                [CompletionResult]::new('register', 'register', [CompletionResultType]::ParameterValue, 'Register a Python binary')
                [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Removes a toolchain')
                break
            }
            'rye;help;toolchain;fetch' {
                break
            }
            'rye;help;toolchain;list' {
                break
            }
            'rye;help;toolchain;register' {
                break
            }
            'rye;help;toolchain;remove' {
                break
            }
            'rye;help;tools' {
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Installs a package as global tool')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls a global tool')
                [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all registered tools')
                break
            }
            'rye;help;tools;install' {
                break
            }
            'rye;help;tools;uninstall' {
                break
            }
            'rye;help;tools;list' {
                break
            }
            'rye;help;self' {
                [CompletionResult]::new('completion', 'completion', [CompletionResultType]::ParameterValue, 'Generates a completion script for a shell')
                [CompletionResult]::new('update', 'update', [CompletionResultType]::ParameterValue, 'Performs an update of rye')
                [CompletionResult]::new('install', 'install', [CompletionResultType]::ParameterValue, 'Triggers the initial installation of Rye')
                [CompletionResult]::new('uninstall', 'uninstall', [CompletionResultType]::ParameterValue, 'Uninstalls rye again')
                break
            }
            'rye;help;self;completion' {
                break
            }
            'rye;help;self;update' {
                break
            }
            'rye;help;self;install' {
                break
            }
            'rye;help;self;uninstall' {
                break
            }
            'rye;help;uninstall' {
                break
            }
            'rye;help;version' {
                break
            }
            'rye;help;list' {
                break
            }
            'rye;help;shell' {
                break
            }
            'rye;help;help' {
                break
            }
        })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
    Sort-Object -Property ListItemText
}
