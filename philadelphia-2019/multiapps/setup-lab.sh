export SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
source ${SCRIPT_DIR}/scripts/wget_plugin_mbt.sh
source ${SCRIPT_DIR}/scripts/login.sh

(git clone https://github.com/ddonchev/multiapps-handson ${HOME}/mtalab)
cd ${HOME}/mtalab
(git checkout master ; git reset --hard origin/master)