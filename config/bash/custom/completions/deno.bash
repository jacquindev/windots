_deno() {
    local i cur prev opts cmd
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd=""
    opts=""

    for i in ${COMP_WORDS[@]}
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="deno"
                ;;
            deno,add)
                cmd="deno__add"
                ;;
            deno,bench)
                cmd="deno__bench"
                ;;
            deno,bundle)
                cmd="deno__bundle"
                ;;
            deno,cache)
                cmd="deno__cache"
                ;;
            deno,check)
                cmd="deno__check"
                ;;
            deno,clean)
                cmd="deno__clean"
                ;;
            deno,compile)
                cmd="deno__compile"
                ;;
            deno,completions)
                cmd="deno__completions"
                ;;
            deno,coverage)
                cmd="deno__coverage"
                ;;
            deno,doc)
                cmd="deno__doc"
                ;;
            deno,eval)
                cmd="deno__eval"
                ;;
            deno,fmt)
                cmd="deno__fmt"
                ;;
            deno,help)
                cmd="deno__help"
                ;;
            deno,i)
                cmd="deno__install"
                ;;
            deno,info)
                cmd="deno__info"
                ;;
            deno,init)
                cmd="deno__init"
                ;;
            deno,install)
                cmd="deno__install"
                ;;
            deno,json_reference)
                cmd="deno__json_reference"
                ;;
            deno,jupyter)
                cmd="deno__jupyter"
                ;;
            deno,lint)
                cmd="deno__lint"
                ;;
            deno,lsp)
                cmd="deno__lsp"
                ;;
            deno,outdated)
                cmd="deno__outdated"
                ;;
            deno,publish)
                cmd="deno__publish"
                ;;
            deno,remove)
                cmd="deno__remove"
                ;;
            deno,repl)
                cmd="deno__repl"
                ;;
            deno,run)
                cmd="deno__run"
                ;;
            deno,serve)
                cmd="deno__serve"
                ;;
            deno,task)
                cmd="deno__task"
                ;;
            deno,test)
                cmd="deno__test"
                ;;
            deno,types)
                cmd="deno__types"
                ;;
            deno,uninstall)
                cmd="deno__uninstall"
                ;;
            deno,upgrade)
                cmd="deno__upgrade"
                ;;
            deno,vendor)
                cmd="deno__vendor"
                ;;
            deno__help,add)
                cmd="deno__help__add"
                ;;
            deno__help,bench)
                cmd="deno__help__bench"
                ;;
            deno__help,bundle)
                cmd="deno__help__bundle"
                ;;
            deno__help,cache)
                cmd="deno__help__cache"
                ;;
            deno__help,check)
                cmd="deno__help__check"
                ;;
            deno__help,clean)
                cmd="deno__help__clean"
                ;;
            deno__help,compile)
                cmd="deno__help__compile"
                ;;
            deno__help,completions)
                cmd="deno__help__completions"
                ;;
            deno__help,coverage)
                cmd="deno__help__coverage"
                ;;
            deno__help,doc)
                cmd="deno__help__doc"
                ;;
            deno__help,eval)
                cmd="deno__help__eval"
                ;;
            deno__help,fmt)
                cmd="deno__help__fmt"
                ;;
            deno__help,info)
                cmd="deno__help__info"
                ;;
            deno__help,init)
                cmd="deno__help__init"
                ;;
            deno__help,install)
                cmd="deno__help__install"
                ;;
            deno__help,json_reference)
                cmd="deno__help__json_reference"
                ;;
            deno__help,jupyter)
                cmd="deno__help__jupyter"
                ;;
            deno__help,lint)
                cmd="deno__help__lint"
                ;;
            deno__help,lsp)
                cmd="deno__help__lsp"
                ;;
            deno__help,outdated)
                cmd="deno__help__outdated"
                ;;
            deno__help,publish)
                cmd="deno__help__publish"
                ;;
            deno__help,remove)
                cmd="deno__help__remove"
                ;;
            deno__help,repl)
                cmd="deno__help__repl"
                ;;
            deno__help,run)
                cmd="deno__help__run"
                ;;
            deno__help,serve)
                cmd="deno__help__serve"
                ;;
            deno__help,task)
                cmd="deno__help__task"
                ;;
            deno__help,test)
                cmd="deno__help__test"
                ;;
            deno__help,types)
                cmd="deno__help__types"
                ;;
            deno__help,uninstall)
                cmd="deno__help__uninstall"
                ;;
            deno__help,upgrade)
                cmd="deno__help__upgrade"
                ;;
            deno__help,vendor)
                cmd="deno__help__vendor"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        deno)
            opts="-c -r -A -R -W -N -E -S -I -h -V -L -q --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --inspect --inspect-brk --inspect-wait --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --check --watch --watch-hmr --watch-exclude --no-clear-screen --ext --env-file --no-code-cache --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --version --log-level --quiet [SCRIPT_ARG]... run serve add remove bench bundle cache check clean compile completions coverage doc eval fmt init info install i json_reference jupyter uninstall outdated lsp lint publish repl task test types upgrade vendor help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-hmr)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__add)
            opts="-h -L -q -D --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --dev --allow-scripts [packages]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__bench)
            opts="-h -L -q -c -r -A -R -W -N -E -S -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --check --json --ignore --filter --no-run --watch --watch-exclude --no-clear-screen --env-file --ext [files]... [SCRIPT_ARG]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ignore)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --filter)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__bundle)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__cache)
            opts="-h -L -q -c -r -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --check --frozen --allow-scripts --allow-import [file]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__check)
            opts="-h -L -q -c -r -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --all --remote --doc --doc-only --frozen --allow-import [file]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__clean)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__compile)
            opts="-h -L -q -c -r -A -R -W -N -E -S -I -o --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --check --include --output --target --no-code-cache --no-terminal --icon --ext --env-file [SCRIPT_ARG]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --include)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -o)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --target)
                    COMPREPLY=($(compgen -W "x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu x86_64-pc-windows-msvc x86_64-apple-darwin aarch64-apple-darwin" -- "${cur}"))
                    return 0
                    ;;
                --icon)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__completions)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet bash fish powershell zsh fig"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__coverage)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --ignore --include --exclude --lcov --output --html --detailed [files]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --ignore)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --include)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__doc)
            opts="-h -L -q -r -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --import-map --reload --lock --no-lock --no-npm --no-remote --allow-import --json --html --name --category-docs --symbol-redirect-map --strip-trailing-html --default-symbol-map --output --private --filter --lint [source_file]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --name)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --category-docs)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --symbol-redirect-map)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --default-symbol-map)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --filter)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__eval)
            opts="-h -L -q -c -r -p --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --inspect --inspect-brk --inspect-wait --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --check --ext --print --env-file [CODE_ARG]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__fmt)
            opts="-h -L -q -c --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --config --no-config --check --ext --ignore --watch --watch-exclude --no-clear-screen --use-tabs --line-width --indent-width --single-quote --prose-wrap --no-semicolons --unstable-css --unstable-html --unstable-component --unstable-yaml --unstable-sql [files]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx md json jsonc css scss sass less html svelte vue astro yml yaml ipynb sql" -- "${cur}"))
                    return 0
                    ;;
                --ignore)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --use-tabs)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --line-width)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --indent-width)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --single-quote)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --prose-wrap)
                    COMPREPLY=($(compgen -W "always never preserve" -- "${cur}"))
                    return 0
                    ;;
                --no-semicolons)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet run serve add remove bench bundle cache check clean compile completions coverage doc eval fmt init info install json_reference jupyter uninstall outdated lsp lint publish repl task test types upgrade vendor"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__add)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__bench)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__bundle)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__cache)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__check)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__clean)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__compile)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__completions)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__coverage)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__doc)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__eval)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__fmt)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__info)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__init)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__install)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__json_reference)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__jupyter)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__lint)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__lsp)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__outdated)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__publish)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__remove)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__repl)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__run)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__serve)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__task)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__test)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__types)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__uninstall)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__upgrade)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__help__vendor)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__info)
            opts="-I -h -L -q -r -c --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --allow-import --help --log-level --quiet --reload --cert --unsafely-ignore-certificate-errors --location --no-check --no-config --no-remote --no-npm --lock --no-lock --config --import-map --node-modules-dir --vendor --json [file]"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__init)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --npm --lib --serve [DIRECTORY OR PACKAGE]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__install)
            opts="-h -L -q -c -r -A -R -W -N -E -S -I -n -f -g -e -D --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --inspect --inspect-brk --inspect-wait --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --check --allow-scripts --name --root --force --global --entrypoint --env-file --dev [cmd]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --name)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -n)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --root)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__install)
            opts="-h -L -q -c -r -A -R -W -N -E -S -I -n -f -g -e -D --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --inspect --inspect-brk --inspect-wait --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --check --allow-scripts --name --root --force --global --entrypoint --env-file --dev [cmd]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --name)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -n)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --root)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__json_reference)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__jupyter)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --install --kernel --conn --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --conn)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__lint)
            opts="-h -L -q -c -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --fix --ext --rules --rules-tags --rules-include --rules-exclude --no-config --config --ignore --json --compact --watch --watch-exclude --no-clear-screen --allow-import [files]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rules-tags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rules-include)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rules-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --ignore)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__lsp)
            opts="-h -L -q --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__outdated)
            opts="-h -L -q -u -r --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-lock --lock --latest --update --compatible --recursive [filters]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__publish)
            opts="-h -L -q -c --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --token --config --no-config --dry-run --allow-slow-types --allow-dirty --no-provenance --set-version --check --no-check"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --token)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --set-version)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__remove)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet [packages]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__repl)
            opts="-h -L -q -c -r -A -R -W -N -E -S -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --env-file --help --log-level --quiet --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --inspect --inspect-brk --inspect-wait --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --eval-file --eval [ARGS]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --eval-file)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --eval)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__run)
            opts="-c -r -A -R -W -N -E -S -I -h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --inspect --inspect-brk --inspect-wait --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --check --watch --watch-hmr --watch-exclude --no-clear-screen --ext --env-file --no-code-cache --help --log-level --quiet [SCRIPT_ARG]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-hmr)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__serve)
            opts="-c -r -A -R -W -N -E -S -I -h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --inspect --inspect-brk --inspect-wait --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --port --host --parallel --check --watch --watch-hmr --watch-exclude --no-clear-screen --ext --env-file --no-code-cache --help --log-level --quiet [SCRIPT_ARG]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --port)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --host)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-hmr)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__task)
            opts="-h -L -q -c -r -f --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --config --cwd --recursive --filter --eval --node-modules-dir"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cwd)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                --filter)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__test)
            opts="-h -L -q -c -r -A -R -W -N -E -S -I --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --no-check --import-map --no-remote --no-npm --node-modules-dir --vendor --config --no-config --reload --lock --no-lock --cert --unsafely-ignore-certificate-errors --allow-all --allow-read --deny-read --allow-write --deny-write --allow-net --deny-net --allow-env --deny-env --allow-sys --deny-sys --allow-run --deny-run --allow-ffi --deny-ffi --allow-hrtime --deny-hrtime --no-prompt --allow-import --inspect --inspect-brk --inspect-wait --allow-scripts --frozen --cached-only --location --v8-flags --seed --enable-testing-features-do-not-use --strace-ops --check --ignore --no-run --trace-leaks --doc --fail-fast --permit-no-files --filter --shuffle --coverage --clean --parallel --watch --watch-exclude --no-clear-screen --junit-path --reporter --hide-stacktraces --env-file --ext [files]... [SCRIPT_ARG]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --no-check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --import-map)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --node-modules-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vendor)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -c)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reload)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                -r)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --lock)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -R)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-read)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -W)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-write)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -N)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-net)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -E)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-env)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -S)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-sys)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-run)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --deny-ffi)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-import)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -I)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-brk)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inspect-wait)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --allow-scripts)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --frozen)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --location)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --v8-flags)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strace-ops)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --check)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --ignore)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --fail-fast)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --filter)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --shuffle)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --coverage)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --watch-exclude)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --junit-path)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --reporter)
                    COMPREPLY=($(compgen -W "pretty dot junit tap" -- "${cur}"))
                    return 0
                    ;;
                --env-file)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --ext)
                    COMPREPLY=($(compgen -W "ts tsx js jsx" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__types)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__uninstall)
            opts="-h -L -q -g --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --root --global [name-or-package] [additional-packages]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --root)
                    COMPREPLY=()
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o plusdirs
                    fi
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__upgrade)
            opts="-h -L -q -f --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet --version --output --dry-run --force --canary --rc --cert --unsafely-ignore-certificate-errors [VERSION]..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                --version)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --cert)
                    local oldifs
                    if [ -n "${IFS+x}" ]; then
                        oldifs="$IFS"
                    fi
                    IFS=$'\n'
                    COMPREPLY=($(compgen -f "${cur}"))
                    if [ -n "${oldifs+x}" ]; then
                        IFS="$oldifs"
                    fi
                    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
                        compopt -o filenames
                    fi
                    return 0
                    ;;
                --unsafely-ignore-certificate-errors)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        deno__vendor)
            opts="-h -L -q --unstable --unstable-bare-node-builtins --unstable-detect-cjs --unstable-byonm --unstable-sloppy-imports --unstable-npm-lazy-caching --unstable-broadcast-channel --unstable-cron --unstable-ffi --unstable-fs --unstable-http --unstable-kv --unstable-net --unstable-node-globals --unstable-otel --unstable-process --unstable-temporal --unstable-unsafe-proto --unstable-webgpu --unstable-worker-options --help --log-level --quiet"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --help)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                -h)
                    COMPREPLY=($(compgen -W "unstable" -- "${cur}"))
                    return 0
                    ;;
                --log-level)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                -L)
                    COMPREPLY=($(compgen -W "trace debug info" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _deno -o nosort -o bashdefault -o default deno
else
    complete -F _deno -o bashdefault -o default deno
fi
