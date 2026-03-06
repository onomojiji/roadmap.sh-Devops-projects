#! /bin/bash

local_site="/path/to/local/site/dir"
remote_ssh_user="remote-user"
remote_ip="remopte-ip-or-address"
remote_site="/path/to/remote/site/dir"

rsync -avh $local_site $remote_ssh_user@$remote_ip:$remote_site
