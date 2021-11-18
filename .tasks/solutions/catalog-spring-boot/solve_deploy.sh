################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/catalog-spring-boot
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
odo delete --all --force
odo project set ${PROJECT_NAME}
odo create java-springboot catalog --app coolstore
odo url create catalog --port 8080
odo push

oc label deployment catalog-coolstore app.openshift.io/runtime=spring --overwrite

echo "Catalog Spring-Boot Deployed"