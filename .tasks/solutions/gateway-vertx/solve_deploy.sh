##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-vertx
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}

odo delete --all --force
odo project set ${PROJECT_NAME}
odo create java-vertx gateway --app coolstore
odo url create gateway --port 8080
odo push

oc annotate --overwrite deployment/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc label deployment gateway-coolstore app.openshift.io/runtime=vertx --overwrite

echo "Gateway Vertx Deployed"