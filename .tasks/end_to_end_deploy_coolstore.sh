####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`
USER_ID=$1

$DIRECTORY/inner_loop_deploy_coolstore.sh my-project${USER_ID} && \
    $DIRECTORY/outer_loop_deploy_coolstore.sh ${USER_ID}
    