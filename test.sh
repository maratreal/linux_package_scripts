#!/bin/bash

echo "ftp server [enter]:"
read server

echo "ftp login [enter]:"
read login

echo "ftp password [enter]:"
read -s password

wget ftp://$login:$password@$server/files/linux/1c.tar.gz
