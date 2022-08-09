set -x
oc get checluster --all-namespaces -o=jsonpath="{.items[*].metadata.namespace}"
~/Projects/CRW/dsc/bin/dsc server:delete -n openshift-operators
oc delete devworkspaces.workspace.devfile.io --all-namespaces --selector 'console.openshift.io/terminal=true' --wait 
oc delete devworkspacetemplates.workspace.devfile.io --all-namespaces --selector 'console.openshift.io/terminal=true' --wait 
oc delete devworkspaces.workspace.devfile.io --all-namespaces --all --wait
oc delete devworkspaceroutings.controller.devfile.io --all-namespaces --all
oc delete customresourcedefinitions.apiextensions.k8s.io devworkspaceroutings.controller.devfile.io
oc delete customresourcedefinitions.apiextensions.k8s.io devworkspaces.workspace.devfile.io
oc delete customresourcedefinitions.apiextensions.k8s.io devworkspacetemplates.workspace.devfile.io
oc delete customresourcedefinitions.apiextensions.k8s.io devworkspaceoperatorconfigs.controller.devfile.io
# oc get customresourcedefinitions.apiextensions.k8s.io | grep "devfile.io"
oc delete deployment/devworkspace-webhook-server -n openshift-operators
oc delete mutatingwebhookconfigurations controller.devfile.io
oc delete validatingwebhookconfigurations controller.devfile.io
oc delete all --selector app.kubernetes.io/part-of=devworkspace-operator,app.kubernetes.io/name=devworkspace-webhook-server -n openshift-operators
oc delete serviceaccounts devworkspace-webhook-server -n openshift-operators
oc delete configmap devworkspace-controller -n openshift-operators
oc delete clusterrole devworkspace-webhook-server
oc delete clusterrolebinding devworkspace-webhook-server
#
echo "Now uninstall the Dev WorkSpace Operator"
