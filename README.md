# docker-apache-workbench-tool
Docker image based on tiny-tools with additional network tools and Apache workbench for load testing

Image is based on alpine.

## Github pipeline and published image

The github pipeline takes care of the multi-arch build, and publishes the image to the Github Container Registry.

```
docker pull ghcr.io/fabianlee/apache-workbench-tools.yaml:latest
```

## Creating tag that invokes Github Action

```
newtag=v1.0.1
git commit -a -m "changes for new tag $newtag" && git push -o ci.skip
git tag $newtag && git push origin $newtag
```

## Deleting tag

```
# delete local tag, then remote
todel=v1.0.1
git tag -d $todel && git push -d origin $todel
```

## Deploying to Kubernetes cluster

If you want to test this container image from a Kubernetes cluster, you can use the example manifest provided.

```
kubectl apply -f apache-workbench-tools.yaml
```

