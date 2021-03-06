#########################
# Service Mesh Solution #
#########################

DIRECTORY=`dirname $0`
USER_ID=$1
APPS_HOSTNAME_SUFFIX=$(oc whoami --show-console | sed 's%.*\(apps.*\)$%\1%g')

oc project cn-project${USER_ID}

oc patch deployment/catalog-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}

oc patch deployment/inventory-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}

oc patch deployment/gateway-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: ingressgateway
  namespace: cn-project${USER_ID}
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "ingressgateway-cn-project${USER_ID}.${APPS_HOSTNAME_SUFFIX}"
EOF

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: gateway-coolstore
  namespace: cn-project${USER_ID}
spec:
  hosts:
    - "ingressgateway-cn-project${USER_ID}.${APPS_HOSTNAME_SUFFIX}"
  gateways:
    - ingressgateway
  http:
    - route:
        - destination:
            port:
              number: 8080
            host: gateway-coolstore
EOF

oc set env deployment/web-coolstore COOLSTORE_GW_ENDPOINT="http://ingressgateway-cn-project${USER_ID}.${APPS_HOSTNAME_SUFFIX}"

oc new-app https://github.com/RedHat-EMEA-SSA-Team/end-to-end-developer-workshop \
    --strategy=docker \
    --context-dir=/labs/catalog-go \
    --name=catalog-coolstore-v2 \
    --labels=app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=golang

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: catalog-coolstore
  namespace: cn-project${USER_ID}
spec:
  hosts:
    - catalog-coolstore
  http:
  - route:
    - destination:
        host: catalog-coolstore
      weight: 0
    - destination:
        host: catalog-coolstore-v2
      weight: 100
EOF