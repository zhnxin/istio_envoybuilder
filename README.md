# istio envoy builder

istio envoy编译环境依赖.

```
docker build --build-arg ISTIO_TAG=1.6.7 -t istio/envoybuilder:1.6.7 .
```

## usage Dockerfile
```
FROM istio/envoybuilder:1.6.7 as builder
ENV EXTRACTED_CLANG_LLVM="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04" \
    PATH="$HOME/go/bin:/root/${EXTRACTED_CLANG_LLVM}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/llvm-9/bin" \
    BAZEL_BUILD_ARGS="--override_repository=envoy=/root/envoy" \
    CC=clang \
    CXX=clang++
ADD envoy /root/envoy
RUN cd /root/go/src/istio.io/proxy &&\
    make build_envoy &&\
    mkdir /app && mv /root/go/src/istio.io/proxy/bazel-bin/src/envoy/envoy /app/envoy

FROM istio/proxyv2:1.6.7
MAINTAINER Zhengxin <zhngxin@aliyun.com>
COPY --from=builder /app/envoy /usr/local/bin/envoy
```