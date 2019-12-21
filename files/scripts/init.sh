#!/bin/sh
set -e

CONFIG_PATH=/config
DATA_PATH=/data

# Timezone setting
if [ -n "${TZ}" ]; then
  echo "$(date '+%Y-%m-%d %H:%m') INIT     Local timezone to ${TZ}"
  echo "${TZ}" > /etc/timezone
  cp /usr/share/zoneinfo/"${TZ}" /etc/localtime
fi

# PUID and PGUID
cd $DATA_PATH || exit

echo "$(date '+%Y-%m-%d %H:%m') INIT     Setting permissions on files/folders inside container"
if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
  if [ -z "$(getent group "${PGID}")" ]; then
    groupadd -g "${PGID}" flexget
  fi

  if [ -z "$(getent passwd "${PUID}")" ]; then
    useradd -M -s /bin/sh -u "${PUID}" -g "${PGID}" flexget
  fi

  flex_user=$(getent passwd "${PUID}" | cut -d: -f1)
  flex_group=$(getent group "${PGID}" | cut -d: -f1)

  chown -R "${flex_user}":"${flex_group}" $DATA_PATH
  chmod -R 775 $DATA_PATH
fi

# Remove lockfile if exists
if [ -f $DATA_PATH/.config-lock ]; then
  echo "$(date '+%Y-%m-%d %H:%m') INIT     Removing lockfile"
  rm -f $DATA_PATH/.config-lock
fi

# Check if config.yml exists. If not, copy in
if [ -f $CONFIG_PATH/config.yml ]; then
  echo "$(date '+%Y-%m-%d %H:%m') INIT     Using existing config.yml"
else
  echo "$(date '+%Y-%m-%d %H:%m') INIT     New config.yml from template"
  cp /scripts/config.example.yml $CONFIG_PATH/config.yml
  if [ -n "$flex_user" ]; then
    chown "${flex_user}":"${flex_group}" $CONFIG_PATH/config.yml
  fi
fi
ln -sf $CONFIG_PATH/config.yml $DATA_PATH/config.yml

# Set FG_WEBUI_PASSWD
if [[ ! -z "${FG_WEBUI_PASSWD}" ]]; then
  echo "$(date '+%Y-%m-%d %H:%m') INIT     Using userdefined FG_WEBUI_PASSWD: ${FG_WEBUI_PASSWD}"
  flexget web passwd "${FG_WEBUI_PASSWD}"
fi

echo "$(date '+%Y-%m-%d %H:%m') INIT     Starting flexget daemon by executing"
flexget_command="flexget -c $DATA_PATH/config.yml --loglevel ${FG_LOG_LEVEL:-info} daemon start --autoreload-config"
echo "$(date '+%Y-%m-%d %H:%m') INIT     $flexget_command"
if [ -n "$flex_user" ]; then
  exec su "${flex_user}" -m -c "${flexget_command}"
else
  exec $flexget_command
fi
