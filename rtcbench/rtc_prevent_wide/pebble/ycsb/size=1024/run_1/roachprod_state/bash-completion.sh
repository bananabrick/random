# bash completion for roachprod                            -*- shell-script -*-

__roachprod_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__roachprod_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__roachprod_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__roachprod_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__roachprod_handle_go_custom_completion()
{
    __roachprod_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly roachprod allows to handle aliases
    args=("${words[@]:1}")
    requestComp="${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __roachprod_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __roachprod_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __roachprod_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __roachprod_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __roachprod_debug "${FUNCNAME[0]}: the completions are: ${out[*]}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __roachprod_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __roachprod_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __roachprod_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out[*]}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __roachprod_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subDir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out[0]}")
        if [ -n "$subdir" ]; then
            __roachprod_debug "Listing directories in $subdir"
            __roachprod_handle_subdirs_in_dir_flag "$subdir"
        else
            __roachprod_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out[*]}" -- "$cur")
    fi
}

__roachprod_handle_reply()
{
    __roachprod_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __roachprod_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __roachprod_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __roachprod_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __roachprod_custom_func >/dev/null; then
			# try command name qualified custom func
			__roachprod_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__roachprod_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__roachprod_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__roachprod_handle_flag()
{
    __roachprod_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __roachprod_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __roachprod_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __roachprod_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __roachprod_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __roachprod_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__roachprod_handle_noun()
{
    __roachprod_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __roachprod_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __roachprod_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__roachprod_handle_command()
{
    __roachprod_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_roachprod_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __roachprod_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__roachprod_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __roachprod_handle_reply
        return
    fi
    __roachprod_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __roachprod_handle_flag
    elif __roachprod_contains_word "${words[c]}" "${commands[@]}"; then
        __roachprod_handle_command
    elif [[ $c -eq 0 ]]; then
        __roachprod_handle_command
    elif __roachprod_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __roachprod_handle_command
        else
            __roachprod_handle_noun
        fi
    else
        __roachprod_handle_noun
    fi
    __roachprod_handle_word
}

__custom_func()
	{
		# only complete the 2nd arg, e.g. adminurl <foo>
		if ! [ $c -eq 2 ]; then
			return
		fi

		# don't complete commands which do not accept a cluster/host arg
		case ${last_command} in
			roachprod_create | roachprod_list | roachprod_sync | roachprod_gc)
				return
				;;
		esac

		local hosts_out
		if hosts_out=$(roachprod cached-hosts --cluster="${cur}" 2>/dev/null); then
				COMPREPLY=( $( compgen -W "${hosts_out[*]}" -- "$cur" ) )
		fi

	}
_roachprod_create()
{
    last_command="roachprod_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--aws-	iam-profile=")
    two_word_flags+=("--aws-	iam-profile")
    local_nonpersistent_flags+=("--aws-	iam-profile")
    local_nonpersistent_flags+=("--aws-	iam-profile=")
    flags+=("--aws-config=")
    two_word_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config=")
    flags+=("--aws-cpu-options=")
    two_word_flags+=("--aws-cpu-options")
    local_nonpersistent_flags+=("--aws-cpu-options")
    local_nonpersistent_flags+=("--aws-cpu-options=")
    flags+=("--aws-create-rate-limit=")
    two_word_flags+=("--aws-create-rate-limit")
    local_nonpersistent_flags+=("--aws-create-rate-limit")
    local_nonpersistent_flags+=("--aws-create-rate-limit=")
    flags+=("--aws-ebs-iops=")
    two_word_flags+=("--aws-ebs-iops")
    local_nonpersistent_flags+=("--aws-ebs-iops")
    local_nonpersistent_flags+=("--aws-ebs-iops=")
    flags+=("--aws-ebs-throughput=")
    two_word_flags+=("--aws-ebs-throughput")
    local_nonpersistent_flags+=("--aws-ebs-throughput")
    local_nonpersistent_flags+=("--aws-ebs-throughput=")
    flags+=("--aws-ebs-volume=")
    two_word_flags+=("--aws-ebs-volume")
    local_nonpersistent_flags+=("--aws-ebs-volume")
    local_nonpersistent_flags+=("--aws-ebs-volume=")
    flags+=("--aws-ebs-volume-size=")
    two_word_flags+=("--aws-ebs-volume-size")
    local_nonpersistent_flags+=("--aws-ebs-volume-size")
    local_nonpersistent_flags+=("--aws-ebs-volume-size=")
    flags+=("--aws-ebs-volume-type=")
    two_word_flags+=("--aws-ebs-volume-type")
    local_nonpersistent_flags+=("--aws-ebs-volume-type")
    local_nonpersistent_flags+=("--aws-ebs-volume-type=")
    flags+=("--aws-enable-multiple-stores")
    local_nonpersistent_flags+=("--aws-enable-multiple-stores")
    flags+=("--aws-image-ami=")
    two_word_flags+=("--aws-image-ami")
    local_nonpersistent_flags+=("--aws-image-ami")
    local_nonpersistent_flags+=("--aws-image-ami=")
    flags+=("--aws-machine-type=")
    two_word_flags+=("--aws-machine-type")
    local_nonpersistent_flags+=("--aws-machine-type")
    local_nonpersistent_flags+=("--aws-machine-type=")
    flags+=("--aws-machine-type-ssd=")
    two_word_flags+=("--aws-machine-type-ssd")
    local_nonpersistent_flags+=("--aws-machine-type-ssd")
    local_nonpersistent_flags+=("--aws-machine-type-ssd=")
    flags+=("--aws-profile=")
    two_word_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile=")
    flags+=("--aws-user=")
    two_word_flags+=("--aws-user")
    local_nonpersistent_flags+=("--aws-user")
    local_nonpersistent_flags+=("--aws-user=")
    flags+=("--aws-zones=")
    two_word_flags+=("--aws-zones")
    local_nonpersistent_flags+=("--aws-zones")
    local_nonpersistent_flags+=("--aws-zones=")
    flags+=("--azure-availability-zone=")
    two_word_flags+=("--azure-availability-zone")
    local_nonpersistent_flags+=("--azure-availability-zone")
    local_nonpersistent_flags+=("--azure-availability-zone=")
    flags+=("--azure-disk-caching=")
    two_word_flags+=("--azure-disk-caching")
    local_nonpersistent_flags+=("--azure-disk-caching")
    local_nonpersistent_flags+=("--azure-disk-caching=")
    flags+=("--azure-locations=")
    two_word_flags+=("--azure-locations")
    local_nonpersistent_flags+=("--azure-locations")
    local_nonpersistent_flags+=("--azure-locations=")
    flags+=("--azure-machine-type=")
    two_word_flags+=("--azure-machine-type")
    local_nonpersistent_flags+=("--azure-machine-type")
    local_nonpersistent_flags+=("--azure-machine-type=")
    flags+=("--azure-network-disk-type=")
    two_word_flags+=("--azure-network-disk-type")
    local_nonpersistent_flags+=("--azure-network-disk-type")
    local_nonpersistent_flags+=("--azure-network-disk-type=")
    flags+=("--azure-sync-delete")
    local_nonpersistent_flags+=("--azure-sync-delete")
    flags+=("--azure-timeout=")
    two_word_flags+=("--azure-timeout")
    local_nonpersistent_flags+=("--azure-timeout")
    local_nonpersistent_flags+=("--azure-timeout=")
    flags+=("--azure-ultra-disk-iops=")
    two_word_flags+=("--azure-ultra-disk-iops")
    local_nonpersistent_flags+=("--azure-ultra-disk-iops")
    local_nonpersistent_flags+=("--azure-ultra-disk-iops=")
    flags+=("--azure-vnet-name=")
    two_word_flags+=("--azure-vnet-name")
    local_nonpersistent_flags+=("--azure-vnet-name")
    local_nonpersistent_flags+=("--azure-vnet-name=")
    flags+=("--azure-volume-size=")
    two_word_flags+=("--azure-volume-size")
    local_nonpersistent_flags+=("--azure-volume-size")
    local_nonpersistent_flags+=("--azure-volume-size=")
    flags+=("--clouds=")
    two_word_flags+=("--clouds")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--clouds")
    local_nonpersistent_flags+=("--clouds=")
    local_nonpersistent_flags+=("-c")
    flags+=("--filesystem=")
    two_word_flags+=("--filesystem")
    local_nonpersistent_flags+=("--filesystem")
    local_nonpersistent_flags+=("--filesystem=")
    flags+=("--gce-image=")
    two_word_flags+=("--gce-image")
    local_nonpersistent_flags+=("--gce-image")
    local_nonpersistent_flags+=("--gce-image=")
    flags+=("--gce-local-ssd-count=")
    two_word_flags+=("--gce-local-ssd-count")
    local_nonpersistent_flags+=("--gce-local-ssd-count")
    local_nonpersistent_flags+=("--gce-local-ssd-count=")
    flags+=("--gce-machine-type=")
    two_word_flags+=("--gce-machine-type")
    local_nonpersistent_flags+=("--gce-machine-type")
    local_nonpersistent_flags+=("--gce-machine-type=")
    flags+=("--gce-min-cpu-platform=")
    two_word_flags+=("--gce-min-cpu-platform")
    local_nonpersistent_flags+=("--gce-min-cpu-platform")
    local_nonpersistent_flags+=("--gce-min-cpu-platform=")
    flags+=("--gce-pd-volume-size=")
    two_word_flags+=("--gce-pd-volume-size")
    local_nonpersistent_flags+=("--gce-pd-volume-size")
    local_nonpersistent_flags+=("--gce-pd-volume-size=")
    flags+=("--gce-pd-volume-type=")
    two_word_flags+=("--gce-pd-volume-type")
    local_nonpersistent_flags+=("--gce-pd-volume-type")
    local_nonpersistent_flags+=("--gce-pd-volume-type=")
    flags+=("--gce-project=")
    two_word_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project=")
    flags+=("--gce-service-account=")
    two_word_flags+=("--gce-service-account")
    local_nonpersistent_flags+=("--gce-service-account")
    local_nonpersistent_flags+=("--gce-service-account=")
    flags+=("--gce-use-shared-user")
    local_nonpersistent_flags+=("--gce-use-shared-user")
    flags+=("--gce-zones=")
    two_word_flags+=("--gce-zones")
    local_nonpersistent_flags+=("--gce-zones")
    local_nonpersistent_flags+=("--gce-zones=")
    flags+=("--geo")
    local_nonpersistent_flags+=("--geo")
    flags+=("--lifetime=")
    two_word_flags+=("--lifetime")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--lifetime")
    local_nonpersistent_flags+=("--lifetime=")
    local_nonpersistent_flags+=("-l")
    flags+=("--local-ssd")
    local_nonpersistent_flags+=("--local-ssd")
    flags+=("--local-ssd-no-ext4-barrier")
    local_nonpersistent_flags+=("--local-ssd-no-ext4-barrier")
    flags+=("--nodes=")
    two_word_flags+=("--nodes")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--nodes")
    local_nonpersistent_flags+=("--nodes=")
    local_nonpersistent_flags+=("-n")
    flags+=("--os-volume-size=")
    two_word_flags+=("--os-volume-size")
    local_nonpersistent_flags+=("--os-volume-size")
    local_nonpersistent_flags+=("--os-volume-size=")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_reset()
{
    last_command="roachprod_reset"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_destroy()
{
    last_command="roachprod_destroy"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all-mine")
    flags+=("-m")
    local_nonpersistent_flags+=("--all-mine")
    local_nonpersistent_flags+=("-m")
    flags+=("--aws-config=")
    two_word_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config=")
    flags+=("--aws-profile=")
    two_word_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile=")
    flags+=("--gce-project=")
    two_word_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project=")
    flags+=("--gce-use-shared-user")
    local_nonpersistent_flags+=("--gce-use-shared-user")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_extend()
{
    last_command="roachprod_extend"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--aws-config=")
    two_word_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config=")
    flags+=("--aws-profile=")
    two_word_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile=")
    flags+=("--gce-project=")
    two_word_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project=")
    flags+=("--gce-use-shared-user")
    local_nonpersistent_flags+=("--gce-use-shared-user")
    flags+=("--lifetime=")
    two_word_flags+=("--lifetime")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--lifetime")
    local_nonpersistent_flags+=("--lifetime=")
    local_nonpersistent_flags+=("-l")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_list()
{
    last_command="roachprod_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--aws-config=")
    two_word_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config=")
    flags+=("--aws-profile=")
    two_word_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile=")
    flags+=("--details")
    flags+=("-d")
    local_nonpersistent_flags+=("--details")
    local_nonpersistent_flags+=("-d")
    flags+=("--gce-project=")
    two_word_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project=")
    flags+=("--gce-use-shared-user")
    local_nonpersistent_flags+=("--gce-use-shared-user")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")
    flags+=("--json")
    local_nonpersistent_flags+=("--json")
    flags+=("--mine")
    flags+=("-m")
    local_nonpersistent_flags+=("--mine")
    local_nonpersistent_flags+=("-m")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_sync()
{
    last_command="roachprod_sync"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--aws-config=")
    two_word_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config=")
    flags+=("--aws-profile=")
    two_word_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile=")
    flags+=("--gce-project=")
    two_word_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project=")
    flags+=("--gce-use-shared-user")
    local_nonpersistent_flags+=("--gce-use-shared-user")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_gc()
{
    last_command="roachprod_gc"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--aws-config=")
    two_word_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config")
    local_nonpersistent_flags+=("--aws-config=")
    flags+=("--aws-profile=")
    two_word_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile")
    local_nonpersistent_flags+=("--aws-profile=")
    flags+=("--dry-run")
    flags+=("-n")
    local_nonpersistent_flags+=("--dry-run")
    local_nonpersistent_flags+=("-n")
    flags+=("--gce-project=")
    two_word_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project")
    local_nonpersistent_flags+=("--gce-project=")
    flags+=("--gce-use-shared-user")
    local_nonpersistent_flags+=("--gce-use-shared-user")
    flags+=("--slack-token=")
    two_word_flags+=("--slack-token")
    local_nonpersistent_flags+=("--slack-token")
    local_nonpersistent_flags+=("--slack-token=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_setup-ssh()
{
    last_command="roachprod_setup-ssh"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_status()
{
    last_command="roachprod_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_monitor()
{
    last_command="roachprod_monitor"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ignore-empty-nodes")
    local_nonpersistent_flags+=("--ignore-empty-nodes")
    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--oneshot")
    local_nonpersistent_flags+=("--oneshot")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_start()
{
    last_command="roachprod_start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--args=")
    two_word_flags+=("--args")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--args")
    local_nonpersistent_flags+=("--args=")
    local_nonpersistent_flags+=("-a")
    flags+=("--binary=")
    two_word_flags+=("--binary")
    two_word_flags+=("-b")
    local_nonpersistent_flags+=("--binary")
    local_nonpersistent_flags+=("--binary=")
    local_nonpersistent_flags+=("-b")
    flags+=("--encrypt")
    local_nonpersistent_flags+=("--encrypt")
    flags+=("--env=")
    two_word_flags+=("--env")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--env")
    local_nonpersistent_flags+=("--env=")
    local_nonpersistent_flags+=("-e")
    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--racks=")
    two_word_flags+=("--racks")
    two_word_flags+=("-r")
    local_nonpersistent_flags+=("--racks")
    local_nonpersistent_flags+=("--racks=")
    local_nonpersistent_flags+=("-r")
    flags+=("--secure")
    local_nonpersistent_flags+=("--secure")
    flags+=("--sequential")
    local_nonpersistent_flags+=("--sequential")
    flags+=("--skip-init")
    local_nonpersistent_flags+=("--skip-init")
    flags+=("--store-count=")
    two_word_flags+=("--store-count")
    local_nonpersistent_flags+=("--store-count")
    local_nonpersistent_flags+=("--store-count=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_stop()
{
    last_command="roachprod_stop"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--sig=")
    two_word_flags+=("--sig")
    local_nonpersistent_flags+=("--sig")
    local_nonpersistent_flags+=("--sig=")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_init()
{
    last_command="roachprod_init"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_run()
{
    last_command="roachprod_run"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--secure")
    local_nonpersistent_flags+=("--secure")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_wipe()
{
    last_command="roachprod_wipe"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--preserve-certs")
    local_nonpersistent_flags+=("--preserve-certs")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_reformat()
{
    last_command="roachprod_reformat"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_install()
{
    last_command="roachprod_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_distribute-certs()
{
    last_command="roachprod_distribute-certs"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_put()
{
    last_command="roachprod_put"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--treedist")
    local_nonpersistent_flags+=("--treedist")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_get()
{
    last_command="roachprod_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_stage()
{
    last_command="roachprod_stage"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dir=")
    two_word_flags+=("--dir")
    local_nonpersistent_flags+=("--dir")
    local_nonpersistent_flags+=("--dir=")
    flags+=("--os=")
    two_word_flags+=("--os")
    local_nonpersistent_flags+=("--os")
    local_nonpersistent_flags+=("--os=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_download()
{
    last_command="roachprod_download"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_sql()
{
    last_command="roachprod_sql"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--binary=")
    two_word_flags+=("--binary")
    two_word_flags+=("-b")
    local_nonpersistent_flags+=("--binary")
    local_nonpersistent_flags+=("--binary=")
    local_nonpersistent_flags+=("-b")
    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--secure")
    local_nonpersistent_flags+=("--secure")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_ip()
{
    last_command="roachprod_ip"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--external")
    local_nonpersistent_flags+=("--external")
    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_pgurl()
{
    last_command="roachprod_pgurl"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--external")
    local_nonpersistent_flags+=("--external")
    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--secure")
    local_nonpersistent_flags+=("--secure")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_adminurl()
{
    last_command="roachprod_adminurl"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--insecure-ignore-host-key")
    local_nonpersistent_flags+=("--insecure-ignore-host-key")
    flags+=("--ips")
    local_nonpersistent_flags+=("--ips")
    flags+=("--open")
    local_nonpersistent_flags+=("--open")
    flags+=("--path=")
    two_word_flags+=("--path")
    local_nonpersistent_flags+=("--path")
    local_nonpersistent_flags+=("--path=")
    flags+=("--secure")
    local_nonpersistent_flags+=("--secure")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_logs()
{
    last_command="roachprod_logs"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--filter=")
    two_word_flags+=("--filter")
    local_nonpersistent_flags+=("--filter")
    local_nonpersistent_flags+=("--filter=")
    flags+=("--from=")
    two_word_flags+=("--from")
    local_nonpersistent_flags+=("--from")
    local_nonpersistent_flags+=("--from=")
    flags+=("--interval=")
    two_word_flags+=("--interval")
    local_nonpersistent_flags+=("--interval")
    local_nonpersistent_flags+=("--interval=")
    flags+=("--logs-dir=")
    two_word_flags+=("--logs-dir")
    local_nonpersistent_flags+=("--logs-dir")
    local_nonpersistent_flags+=("--logs-dir=")
    flags+=("--logs-program=")
    two_word_flags+=("--logs-program")
    local_nonpersistent_flags+=("--logs-program")
    local_nonpersistent_flags+=("--logs-program=")
    flags+=("--to=")
    two_word_flags+=("--to")
    local_nonpersistent_flags+=("--to")
    local_nonpersistent_flags+=("--to=")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_pprof()
{
    last_command="roachprod_pprof"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--duration=")
    two_word_flags+=("--duration")
    local_nonpersistent_flags+=("--duration")
    local_nonpersistent_flags+=("--duration=")
    flags+=("--heap")
    local_nonpersistent_flags+=("--heap")
    flags+=("--open")
    local_nonpersistent_flags+=("--open")
    flags+=("--starting-port=")
    two_word_flags+=("--starting-port")
    local_nonpersistent_flags+=("--starting-port")
    local_nonpersistent_flags+=("--starting-port=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_cached-hosts()
{
    last_command="roachprod_cached-hosts"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cluster=")
    two_word_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster")
    local_nonpersistent_flags+=("--cluster=")
    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_roachprod_help()
{
    last_command="roachprod_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_roachprod_root_command()
{
    last_command="roachprod"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("reset")
    commands+=("destroy")
    commands+=("extend")
    commands+=("list")
    commands+=("sync")
    commands+=("gc")
    commands+=("setup-ssh")
    commands+=("status")
    commands+=("monitor")
    commands+=("start")
    commands+=("stop")
    commands+=("init")
    commands+=("run")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ssh")
        aliashash["ssh"]="run"
    fi
    commands+=("wipe")
    commands+=("reformat")
    commands+=("install")
    commands+=("distribute-certs")
    commands+=("put")
    commands+=("get")
    commands+=("stage")
    commands+=("download")
    commands+=("sql")
    commands+=("ip")
    commands+=("pgurl")
    commands+=("adminurl")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("admin")
        aliashash["admin"]="adminurl"
        command_aliases+=("adminui")
        aliashash["adminui"]="adminurl"
    fi
    commands+=("logs")
    commands+=("pprof")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("pprof-heap")
        aliashash["pprof-heap"]="pprof"
    fi
    commands+=("cached-hosts")
    commands+=("help")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--max-concurrency=")
    two_word_flags+=("--max-concurrency")
    flags+=("--quiet")
    flags+=("-q")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_roachprod()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __roachprod_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("roachprod")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function
    local last_command
    local nouns=()

    __roachprod_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_roachprod roachprod
else
    complete -o default -o nospace -F __start_roachprod roachprod
fi

# ex: ts=4 sw=4 et filetype=sh
