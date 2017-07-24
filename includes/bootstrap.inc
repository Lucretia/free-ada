########################################################################################################################
# Filename    # bootstrap.inc
# Purpose     # Download and install the bootstrap compiler if required.
# Description #
# Copyright   # Copyright (C) 2011-2017 Luke A. Guest, David Rees.
#             # All Rights Reserved.
########################################################################################################################
function is_bootstrap_required()
{
    command -v foo >/dev/null 2>&1 || return 1
}

function bootstrap_install()
{
    mkdir -p /tmp/free-ada-bootstrap
    cd /tmp/free-ada-bootstrap

    export OLD_PATH=$PATH
    
    export PATH=/tmp/free-ada-bootstrap/bin:$PATH
    
    export PATH=$OLD_PATH
}

function bootstrap_remove()
{
    rm -rf /tmp/free-ada-bootstrap
}
