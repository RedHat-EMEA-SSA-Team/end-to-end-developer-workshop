##########################
# gateway-dotnet Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-dotnet
PROJECT_NAME=$1

cd ${CONTEXT_FOLDER}

oc new-app dotnet:6.0~https://github.com/RedHat-EMEA-SSA-Team/end-to-end-developer-workshop \
        --context-dir=labs/gateway-dotnet \
        --name=gateway-coolstore \
        --labels=app=coolstore,app.kubernetes.io/instance=gateway,app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=gateway,app.openshift.io/runtime=dotnet
oc expose svc gateway

oc annotate --overwrite deployment/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc annotate --overwrite deployment/gateway-coolstore app.kubernetes.io/component-source-type=git

echo "Gateway .NET Deployed"