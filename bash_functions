function genpassword () {
    ## Generate one or several passwords using openssl random generation
    ## We remove ambiguous characters such as I,l,|,0,O
    ITER=1
    if [ ! -z $1 ]
    then
	ITER=$1
    fi
    for i in $(seq 1 ${ITER})
    do
	openssl rand -base64 32 | sed -n 's/[1lIO0\/\+\=]//gp' | cut -b 1-12
    done

}

function pyless () {
    ## Sexier less
    pygmentize -f terminal "$1" | less -R
}

ssh-reagent () {
    ## Connect to a working SSH Agent (started in each bash session for instance, to share the agent across them)
    for agent in /tmp/ssh-*/agent.*; do
        export SSH_AUTH_SOCK=$agent
	if ssh-add -l 2>&1 > /dev/null; then
	    echo Found working SSH Agent:
	    ssh-add -l
	    return 0
	fi
    done
    echo Cannot find ssh agent - maybe you should reconnect and forward it?
    return 1
}

function ikvm () {
    ## Start the iKVM jarball
    [ $# -ne 3 ] && { echo -e "Usage:\tikvm IP USER PASSWORD"; return 1; }

    IKVM_PATH=/opt/ipmiview

    IP=${1}
    USER=${2}
    PASS=${3}

    "${IKVM_PATH}"/jre/bin/java -Djava.library.path="${IKVM_PATH}" -jar "${IKVM_PATH}"/iKVM.jar "${IP}" "${USER}" "${PASS}" null 5900 623 0 0

}

function atoi
{
    ## Returns the integer representation of an IP arg, passed in ascii dotted-decimal notation (x.x.x.x)
    IP=$1; IPNUM=0
    for (( i=0 ; i<4 ; ++i )); do
	((IPNUM+=${IP%%.*}*$((256**$((3-${i}))))))
	IP=${IP#*.}
    done
    echo $IPNUM
}

function itoa
{
    ## Returns the dotted-decimal ascii form of an IP arg passed in integer format
    echo -n $(($(($(($((${1}/256))/256))/256))%256)).
    echo -n $(($(($((${1}/256))/256))%256)).
    echo -n $(($((${1}/256))%256)).
    echo $((${1}%256))
}

