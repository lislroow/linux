#!/bin/bash

nmcli networking off
nmcli networking on
systemctl restart NetworkManager

ifconfig

