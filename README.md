# このREADMEは個人的なメモです

# 事前準備
- Cloud SQL Admin APIを有効化
  - 有効化ボタンではなく「管理」ボタンを押すことで有効化できる

# リソース立ち上げ方法
### 1. クラスター認証
``` shell
gcloud container clusters get-credentials cluster-about-me --zone asia-northeast1
```

### 3. 名前空間作成
``` shell
kubectl apply -f overlays/dev/namespace.yml
```

### 2. GKEサービスアカウント作成
``` shell
kubectl apply -f overlays/dev/sidecar/gke-service-account.yml
```

### 5, GKEサービスアカウントとIAMサービスアカウントの間にIAMポリシーバインディングを追加
``` shell
gcloud iam service-accounts add-iam-policy-binding \
    > dev-gke-sa-about-me@abount-me.iam.gserviceaccount.com \
    > --role="roles/iam.workloadIdentityUser" \
    > --member="serviceAccount:abount-me.svc.id.goog[dev-about-me/dev-gke-sa-about-me]"
```

### 6. DockerイメージをPULLするためのGKEシークレット作成
``` shell
kubectl create secret docker-registry dev-artifact-registry \
    > --docker-server=https://asia-northeast1-docker.pkg.dev \
    > --docker-email=dev-gke-sa-about-me@abount-me.iam.gserviceaccount.com \
    > --docker-username=_json_key \
    > --docker-password="$(cat ./overlays/dev/service-account.json)" \
    > -n dev-about-me
```

### 7. ExternalSecretをインストール
``` shell
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n dev-about-me
```

### 8. ExternalSecretがGCP SecretManagerと通信できるようシークレットを作成
``` shell
kubectl create secret generic dev-gcpsm-secret-001 --from-file=secret-access-credentials=./overlays/dev/service-account.json -n dev-about-me
```

### 9. apply
``` shell
kubectl apply -k overlays/dev
```

# その他便利なコマンド
### Deployment再起動
``` shell
kubectl rollout restart deploy dev-about-me-deployment-001 -n dev-about-me
```

### Podの状態取得
``` shell
kubectl describe pods
```

### プロジェクトの切り替え
``` shell
gcloud config set project abount-me
```
