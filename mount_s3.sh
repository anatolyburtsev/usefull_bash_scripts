#!/bin/sh
set -e

# requirements
sudo apt-get install automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config -y 2>/dev/null 1>&2 || true

sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel -y 2>/dev/null 1>&2 || true


git clone https://github.com/s3fs-fuse/s3fs-fuse.git 2>/dev/null || true
cd s3fs-fuse
./autogen.sh 1>/dev/null
./configure 1>/dev/null
make 1>/dev/null
sudo make install 1>/dev/null
cd ..
sudo sed -i "s/#.*u/u/" /etc/fuse.conf

# set password
if [ ! -f ~/.passwd-s3fs ]; then
	if [ "$#" -lt 2 ]; then
		echo "file with credential not found! Launch like this: $0 MYIDENTITY MY CREDENTIAL"
		exit 1
	fi
	cred="${1}:${2}"
	echo $cred >> ~/.passwd-s3fs
fi
chmod 600 ~/.passwd-s3fs

#mount
cd ~
mkdir -p s3
s3fs ozon-files s3 -o dbglevel=info -o allow_other -o uid=`id -u`
