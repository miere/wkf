# Default settings for all scripts
set -e

if [ "${WRK_DIR}" = "" ]; then
  WRK_DIR=$(dirname $0)/..
fi

for f in "${WRK_DIR}/includes/"*.sh; do
  [ -f "$f" ] || continue
  [ "$(basename "$f")" = "defaults.sh" ] && continue
  source "$f"
done

