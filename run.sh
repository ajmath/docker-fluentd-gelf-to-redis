#!/bin/sh

export EC2_INSTANCE_ID=$(wget -qO- http://169.254.169.254/latest/meta-data/instance-id)
export EC2_INSTANCE_TYPE=$(wget -qO- http://169.254.169.254/latest/meta-data/instance-type)
export EC2_PRIVATE_IP=$(wget -qO- http://169.254.169.254/latest/meta-data/local-ipv4)
export EC2_PUBLIC_IP=$(wget -qO- http://169.254.169.254/latest/meta-data/public-ipv4)
export EC2_AMI_ID=$(wget -qO- http://169.254.169.254/latest/meta-data/ami-id)

if [[ -z "${REDIS_HOST}" || -z "${REDIS_KEY}" ]]; then
  echo "You must specify REDIS_HOST and REDIS_KEY environment variables"
  exit 1
fi

exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT $@
