##############################
# inventory-quarkus Solution #
##############################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/inventory-quarkus
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
mvn clean install -Dquarkus.kubernetes.deploy=true -DskipTests -Dquarkus.container-image.group=$(oc project -q)

#oc label deployment inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

echo "Inventory Quarkus Deployed"