##############################
# inventory-quarkus Solution #
##############################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/inventory-quarkus
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
odo delete --all --force
odo project set ${PROJECT_NAME}
odo create inventory --app coolstore
odo push

oc label deployment inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

echo "Inventory Quarkus Deployed"