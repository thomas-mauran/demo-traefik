#!/bin/bash
IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --tls-san $IP
