#!/bin/sh

sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list # Update the sources list to use archive.debian.org
sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list # Update the security sources as well
sed -i '/buster-updates/d' /etc/apt/sources.list # Remove buster-updates as it is no longer available

echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until # Disable the check for valid-until to avoid issues with expired repository metadata

apt-get update # Update the package lists
apt-get install -y libpq-dev gcc # Install the necessary packages for building psycopg2

pip install -r requirements.txt # Install the Python dependencies from the requirements.txt file