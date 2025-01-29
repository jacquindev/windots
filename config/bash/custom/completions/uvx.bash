_uvx() {
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
                cmd="uvx"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        uvx)
            opts="-i -f -U -P -C -p -n -q -v -h -V --from --with --with-editable --with-requirements --isolated --index --default-index --index-url --extra-index-url --find-links --no-index --upgrade --no-upgrade --upgrade-package --reinstall --no-reinstall --reinstall-package --index-strategy --keyring-provider --resolution --prerelease --pre --fork-strategy --config-setting --no-build-isolation --no-build-isolation-package --build-isolation --exclude-newer --link-mode --compile-bytecode --no-compile-bytecode --no-sources --no-build --build --no-build-package --no-binary --binary --no-binary-package --refresh --no-refresh --refresh-package --python --show-resolution --generate-shell-completion --no-cache --cache-dir --python-preference --allow-python-downloads --no-python-downloads --python-fetch --quiet --verbose --no-color --color --native-tls --no-native-tls --offline --no-offline --allow-insecure-host --preview --no-preview --show-settings --no-progress --no-installer-metadata --directory --project --config-file --no-config --help --version"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --from)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --with)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --with-editable)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --with-requirements)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --index)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --default-index)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --index-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -i)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --extra-index-url)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --find-links)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --upgrade-package)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -P)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --reinstall-package)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --index-strategy)
                    COMPREPLY=($(compgen -W "first-index unsafe-first-match unsafe-best-match" -- "${cur}"))
                    return 0
                    ;;
                --keyring-provider)
                    COMPREPLY=($(compgen -W "disabled subprocess" -- "${cur}"))
                    return 0
                    ;;
                --resolution)
                    COMPREPLY=($(compgen -W "highest lowest lowest-direct" -- "${cur}"))
                    return 0
                    ;;
                --prerelease)
                    COMPREPLY=($(compgen -W "disallow allow if-necessary explicit if-necessary-or-explicit" -- "${cur}"))
                    return 0
                    ;;
                --fork-strategy)
                    COMPREPLY=($(compgen -W "fewest requires-python" -- "${cur}"))
                    return 0
                    ;;
                --config-setting)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -C)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --no-build-isolation-package)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exclude-newer)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --link-mode)
                    COMPREPLY=($(compgen -W "clone copy hardlink symlink" -- "${cur}"))
                    return 0
                    ;;
                --no-build-package)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --no-binary-package)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --refresh-package)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --python)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -p)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --generate-shell-completion)
                    COMPREPLY=($(compgen -W "bash elvish fish nushell powershell zsh" -- "${cur}"))
                    return 0
                    ;;
                --cache-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --python-preference)
                    COMPREPLY=($(compgen -W "only-managed managed system only-system" -- "${cur}"))
                    return 0
                    ;;
                --python-fetch)
                    COMPREPLY=($(compgen -W "automatic manual never" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto always never" -- "${cur}"))
                    return 0
                    ;;
                --allow-insecure-host)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --directory)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --project)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config-file)
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
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _uvx -o nosort -o bashdefault -o default uvx
else
    complete -F _uvx -o bashdefault -o default uvx
fi
