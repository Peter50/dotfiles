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

function ipmi_tunnel () {
    ## Create a SSH tunnel to access the IPMI of a private network-only configured host and use its iKVM features
    [ $# -ne 4 ] && { echo -e "Usage:\tipmi_tunnel LOCAL_IP DESTINATION_IP RELAY_IP PATH_TO_SSH_KEY"; return 1; }

    LOCAL=$1
    DESTINATION=$2
    RELAY=$3
    ARGS=" -i $4 "
    
    sudo ssh $ARGS -L $LOCAL:623:$DESTINATION:623  -L $LOCAL:443:$DESTINATION:443  -L $LOCAL:80:$DESTINATION:80  -L $LOCAL:5900:$DESTINATION:5900 aquaray@$RELAY
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

function sign_ssh_key ()
{
    ## sign my ssh keys against Aqua Ray's arsign infrastructure (cf https://aquawiki.aquaray.com/mediawiki/index.php/AAR:SSH)
    [ $# -ne 3 ] && { echo -e "Usage:\tsign_ssh_key USERNAME PATH_TO_PRIV_KEY KEY_NAME"; return 1; }

    ssh-reagent || { echo -e "Please start a SSH Agent before signing your key"; return 2; }
    
    user=$1
    key=$2
    keyname=$3

    export LC_KEY_TO_SIGN=$3

    echo "Deleting everything in the running agent"
    ssh-add -D
    echo "Deleting previous certificate"
    rm ${key}-cert.pub
    echo "Adding key to the agent"
    ssh-add ${key}
    echo -n "Signing key (enter your password): "
    #	ssh -o SendEnv=LC_KEY_TO_SIGN -t ssh1 "ssh ${user}@arsign1" | grep 'ssh-rsa-cert-v01' | grep ${keyname} > ${key}-cert.pub
    ssh -o SendEnv=LC_KEY_TO_SIGN -t ssh1 "ssh ${user}@arsign1" | grep 'ssh-rsa-cert-v01' > ${key}-cert.pub
    echo ""
    echo "Adding certificate to the agent"
    ssh-add ${key}
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

