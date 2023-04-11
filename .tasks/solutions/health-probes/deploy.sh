##########################
# Health Probes Solution #
##########################

DIRECTORY=`dirname $0`
PROJECT_NAME=$1

oc project ${PROJECT_NAME}
oc policy add-role-to-user view -z default

cp $DIRECTORY/pom.xml $DIRECTORY/../../../labs/inventory-quarkus
cd $DIRECTORY/../../../labs/inventory-quarkus
mvn clean package -Dquarkus.container-image.build=true -DskipTests -Dquarkus.container-image.group=$(oc project -q)

#oc label deployment inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

oc rollout pause deployment/inventory-coolstore
oc set probe deployment/inventory-coolstore --readiness --initial-delay-seconds=10 --failure-threshold=3 --get-url=http://:8080/q/health/ready
oc set probe deployment/inventory-coolstore --liveness --initial-delay-seconds=10 --failure-threshold=3 --get-url=http://:8080/q/health/live
oc rollout resume deployment/inventory-coolstore

echo "Inventory Service Health Probes Done"

oc set probe deployment/catalog-coolstore  --liveness --readiness --initial-delay-seconds=30 --failure-threshold=3 --get-url=http://:8080/actuator/health

echo "Catalog Service Health Probes Done"

oc set probe deployment/gateway-coolstore  --liveness --readiness --period-seconds=5 --get-url=http://:8080/health

echo "Gateway Service Health Probes Done"

oc set probe deployment/web-coolstore --readiness --liveness --period-seconds=5 --get-url=http://:8080/

echo "Web Service Health Probes Done"