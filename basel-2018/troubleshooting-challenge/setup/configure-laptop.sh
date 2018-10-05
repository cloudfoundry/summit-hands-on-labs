# For this script to work export these variables

# CF_API - API enpoint of Cloud Foundry instance
# CF_API=https://api.cf-az.den.altoros.com
# CF_USER - CF user (specific for student)
# CF_USER=azalesov
# CF_PASS - password (specific for student)
# CF_PASS=123
# CF_SPACE - CF space (specific for student)
# CF_SPACE=dev1
# CF_ORG - CF org
# CF_ORG=azalesov

cd 01 && dd if=/dev/zero of=.backup bs=1048576 count=1024

cf login \
        -a $CF_API \
        -o $CF_ORG \
        -p $CF_PASS \
        -s $CF_SPACE \
        -u $CF_USER

alias hint="cat .hint"
alias one-more-hint="cat .hint-2"
alias solution="cat .solution"
