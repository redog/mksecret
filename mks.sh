#!/bin/bash


prog=$0

function tmps {
	TMPPREFIX=$(basename $0)
	TMPDIR=$(mktemp -d)
	trap 'rm -rf $TMPDIR' EXIT
}

function usage {
	#echo "usage: $prog [Description] [ID for reference] [Username] [pool or disk auth]"
	echo "usage: $prog [Description] [ID for reference]"
	exit 1
}

#if [ ${#@} != 4 ]; then
if [ ${#@} != 2 ]; then
	usage
fi

tmps

cat > ${TMPDIR}/${TMPPREFIX}.xml << EOF
<secret ephemeral='no' private='yes'>
   <description>$1</description>
   <usage type='iscsi'>
      <target>$2</target>
   </usage>
</secret>

EOF

MYS=$((virsh secret-define ${TMPDIR}/${TMPPREFIX}.xml) 2>&1 )

UUID=$(echo $MYS | cut -d " " -f 2)

echo -n Password: 
read -s password
echo

MYSECRET=$(printf %s $password | base64)

#echo $MYSECRET
#echo ${UUID}
#virsh secret-list

virsh secret-set-value ${UUID} ${MYSECRET}

