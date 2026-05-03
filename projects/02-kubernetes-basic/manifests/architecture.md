# Kubernetes 構成図

```mermaid
graph LR
    User((ユーザー))

    subgraph Local["🖥️ ローカルマシン"]

        subgraph DockerDesktop["🐳 Docker Desktop"]

            subgraph Minikube["⚙️ Minikube (Kubernetes Node)"]

                subgraph Cluster["Kubernetes Cluster"]

                    Ingress["Ingress<br/>(my-ingress)"]

                    Ingress -- "/api" --> BackendSvc
                    Ingress -- "/" --> NginxSvc
                    Ingress -- "/shop" --> FrontendSvc
                    Ingress -- "/api2" --> BackendSvc2["backend-service2<br/>⚠️ 未定義"]

                    subgraph Nginx["nginx-deployment (replicas: 3)"]
                        NginxPod1["Pod: nginx"]
                        NginxPod2["Pod: nginx"]
                        NginxPod3["Pod: nginx"]
                    end

                    subgraph Backend["backend-api (replicas: 1)"]
                        BackendPod["Pod: http-echo<br/>'Hello API! Backend'"]
                    end

                    subgraph Frontend["frontend-api (replicas: 1)"]
                        FrontendPod["Pod: http-echo<br/>'Hello API! Frontend'"]
                    end

                    NginxSvc["Service<br/>my-nginx-service<br/>(LoadBalancer)"]
                    BackendSvc["Service<br/>backend-service<br/>(ClusterIP)"]
                    FrontendSvc["Service<br/>frontend-service<br/>(ClusterIP)"]

                    NginxSvc --> NginxPod1
                    NginxSvc --> NginxPod2
                    NginxSvc --> NginxPod3
                    BackendSvc --> BackendPod
                    FrontendSvc --> FrontendPod

                    ConfigMap["ConfigMap<br/>nginx-message-config"]
                    Secret["Secret<br/>mysql-pass<br/>⚠️ 未定義"]

                    ConfigMap -.-> NginxPod1
                    ConfigMap -.-> NginxPod2
                    ConfigMap -.-> NginxPod3
                    Secret -.-> NginxPod1
                    Secret -.-> NginxPod2
                    Secret -.-> NginxPod3

                    StandalonePod["Pod: my-nginx-pod<br/>(単体Pod)"]
                end
            end
        end
    end

    User -- "localhost / minikube tunnel" --> Ingress
    User -- "直接アクセス (LoadBalancer)" --> NginxSvc
```

## リソース一覧

| リソース種別 | 名前 | 備考 |
|---|---|---|
| Ingress | my-ingress | パスベースルーティング |
| Deployment | nginx-deployment | replicas: 3, nginx:latest |
| Deployment | backend-api | replicas: 1, hashicorp/http-echo |
| Deployment | frontend-api | replicas: 1, hashicorp/http-echo |
| Service | my-nginx-service | type: LoadBalancer |
| Service | backend-service | type: ClusterIP |
| Service | frontend-service | type: ClusterIP |
| ConfigMap | nginx-message-config | WELCOME_TEXT 用 |
| Secret | mysql-pass | ⚠️ マニフェスト未定義 |
| Pod | my-nginx-pod | 単体Pod（Deployment管理外） |
