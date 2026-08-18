#!/bin/bash

find "$HOME" -type d -name '.git' -readable -prune -print0 |
    xargs -0 -r -P 8 -n 1 sh -c "
        repo=\${1%/.git}
        printf 'Running maintenance in %s\\n' \"\$repo\"
        git -C \"\$repo\" maintenance run
    " sh
