#!/bin/sh

echo "TMP_USER: $TMP_USER"
echo "TMP_UID: $TMP_UID"
echo "TMP_GID: $TMP_GID"
echo "NEW_UID: $NEW_UID"
echo "NEW_GID: $NEW_GID"
echo "CMD: $@"

sed -ie "s/$TMP_GID/$NEW_GID/g" /etc/group
sed -ie "s/$TMP_UID/$NEW_UID/g" /etc/passwd

#su $TMP_USER -c "$@"
su -s /bin/bash $TMP_USER -c "$@"

