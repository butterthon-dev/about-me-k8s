NAMESPACE=dev-about-me

gcloud container clusters get-credentials cluster-about-me --zone asia-northeast1

kubectl delete -f overlays/dev/namespace.yml
kubectl apply -f overlays/dev/namespace.yml

kubectl delete -f overlays/dev/sidecar/gke-service-account.yml
kubectl apply -f overlays/dev/sidecar/gke-service-account.yml

gcloud iam service-accounts add-iam-policy-binding \
    dev-gke-sa-about-me@abount-me.iam.gserviceaccount.com \
    --role="roles/iam.workloadIdentityUser" \
    --member="serviceAccount:abount-me.svc.id.goog[$NAMESPACE/dev-gke-sa-about-me]"

kubectl delete secret dev-artifact-registry -n $NAMESPACE
kubectl create secret docker-registry dev-artifact-registry \
    --docker-server=https://asia-northeast1-docker.pkg.dev \
    --docker-email=dev-gke-sa-about-me@abount-me.iam.gserviceaccount.com \
    --docker-username=_json_key \
    --docker-password="$(cat ./overlays/dev/service-account.json)" \
    -n $NAMESPACE

# helm repo add external-secrets https://charts.external-secrets.io
helm uninstall external-secrets external-secrets/external-secrets -n $NAMESPACE
helm install external-secrets external-secrets/external-secrets -n $NAMESPACE

kubectl delete secret dev-gcpsm-secret-001 -n $NAMESPACE
kubectl create secret generic dev-gcpsm-secret-001 \
    --from-file=secret-access-credentials=./overlays/dev/service-account.json \
    -n $NAMESPACE
