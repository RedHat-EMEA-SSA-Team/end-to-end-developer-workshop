##########################
# gateway-dotnet Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-dotnet
PROJECT_NAME=$1

cd ${CONTEXT_FOLDER}

odo delete --all --force
odo project set ${PROJECT_NAME}
odo create gateway --app coolstore
odo push

oc annotate --overwrite deployment/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc label deployment gateway-coolstore app.openshift.io/runtime=dotnet --overwrite

echo "Gateway .NET Deployed"