export SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
source ${SCRIPT_DIR}/scripts/wget_plugin_mbt.sh
source ${SCRIPT_DIR}/scripts/login.sh

(git clone https://github.com/ddonchev/multiapps-handson ${HOME}/mtalab)
echo "please enter 'cd ${HOME}/mtalab' and follow the instructions on https://github.com/cloudfoundry/summit-hands-on-labs/tree/master/philadelphia-2019/multiapps#table-of-contents"
