eval "$(bbl print-env)"
eval "$(bucc/bin/bucc env)"

set -e

bosh -n stop -d cfcr --force --skip-drain
bosh -n delete-deployment -d cfcr --force

# BBL BUCC UP
if [ -f bbl-state.json ]; then
  bbl down --lb-type concourse --gcp-service-account-key gcp.json --debug
else
  bbl down --lb-type concourse --gcp-service-account-key gcp.json --gcp-region "$GCP_REGION" --debug
fi
