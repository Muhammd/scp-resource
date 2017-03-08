input_json=$(</dev/stdin)

host=$(echo ${input_json} | jq -r '.source.host')
user=$(echo ${input_json} | jq -r '.source.user')
pkey="$(echo ${input_json} | jq -r '.source.private_key')"
glob=$(echo ${input_json} | jq -r '.source.glob')

version=$(echo ${input_json} | jq -r '.version')
[[ ${version} != "null" ]] && version=$(echo "${version}" | jq -r '.path')

keyfile=$(mktemp)

# Make sure to wrap in quotes, or the newlines (which are necessary) are swallowed
pkey=$(echo "${pkey}" | sed -e 's/^-----BEGIN RSA PRIVATE KEY----- \(.*\) -----END RSA PRIVATE KEY-----$/\1/' | tr ' ' '\n')
echo "-----BEGIN RSA PRIVATE KEY-----" > ${keyfile}
echo "${pkey}" >> ${keyfile}
echo "-----END RSA PRIVATE KEY-----" >> ${keyfile}
chmod 600 ${keyfile}

eval $(ssh-agent) > /dev/null 2>&1
ssh-add ${keyfile} > /dev/null 2>&1