#!/usr/bin/env bash

set -eu -o pipefail
${DEBUGSH+set -x}

# doctl compute size list
# or: s-1vcpu-1gb
: "${DO_SIZE=s-1vcpu-2gb}"
ssh="$(doctl compute ssh-key list --format ID --no-header | paste -sd ,)"
# Grab the oldest one because new images take a while to become available
if ! img="$(doctl compute image list | grep "$DO_IMAGE_SLUG" | head -1 | cut -d \  -f 1)"; then
  >&2 echo "Couldn't find Digitalocean image with name $DO_IMAGE_SLUG"
  exit 1
fi
name="dodo-$RANDOM"

# Awkward CLI: first arg, if present, is the userdata file; any other args are
# args to doctl.
userdata=''
if [[ -n ${1-} ]]; then
  userdata="$1"
  shift
fi

exec doctl compute droplet create "$name" \
  --size "$DO_SIZE" \
  --image "$img" \
  --ssh-keys "$ssh" \
  --tag-names nixos,dodo \
  --wait \
  --region "$DO_REGION" \
  ${userdata+--user-data-file "$userdata"} \
  "$@"
