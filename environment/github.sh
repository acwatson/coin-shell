#!/usr/bin/env bash

# This script contains utility functions for interacting with GitHub

# Sets these variables based on this project's GitHub remote origin
# gitProjectGroup
# gitProjectName
# gitRepoDomain
set_github_env_vars_from_remote_origin () {
    local gitRemote=$(git remote get-url --push origin)

    if [[ -z "$gitRemote" ]]; then
        return 1
    elif [[ $gitRemote = https* ]]; then
        local gitApiHost=$([[ $gitRemote =~ (https://[^/]*) ]] && echo ${BASH_REMATCH[1]})
        local projectName=${gitRemote#"$gitApiHost/"}
    elif [[ $gitRemote = http* ]]; then
        local gitApiHost=$([[ $gitRemote =~ (http://[^/]*) ]] && echo ${BASH_REMATCH[1]})
        local projectName=${gitRemote#"$gitApiHost/"}
    else
        local projectName="$(echo "$gitRemote" | sed 's/.*://')"
        local gitApiHost=${gitRemote%":$projectName"}
        gitApiHost=${gitApiHost#*@} # remove everthing up to the @ symbol

        # remove any prefix used by the origin that should not be used for API calls
        if [[ ! -z "$gitRemoteOriginPrefix" ]]; then
            local gitRemoteOriginPrefixLength=${#gitRemoteOriginPrefix}
            gitApiHost=${gitApiHost:$gitRemoteOriginPrefixLength}
        fi
    fi

    gitRepoDomain="$gitApiHost"

    local gitName="${projectName##*/}" # example value: myrepo.git
    gitProjectGroup=${projectName%/$gitName}; #Remove suffix
    gitProjectName=${gitName%.git}
}
