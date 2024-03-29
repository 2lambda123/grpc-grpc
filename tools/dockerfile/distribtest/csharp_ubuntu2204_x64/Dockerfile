# Copyright 2015 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y apt-transport-https gnupg && apt-get clean

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    mono-devel \
    nuget \
    && apt-get clean

RUN apt-get update && apt-get install -y curl && apt-get clean

# Install dotnet SDK
ENV DOTNET_SDK_VERSION 2.1.500
RUN curl -sSL -o dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN apt-get update && apt-get install -y unzip && apt-get clean

# Make sure the mono certificate store is up to date to prevent issues with nuget restore
RUN apt-get update && apt-get install -y curl && apt-get clean
RUN curl https://curl.haxx.se/ca/cacert.pem > ~/cacert.pem && cert-sync ~/cacert.pem && rm -f ~/cacert.pem

# libssl 1.0. Ubuntu22.04 only has libssl 3
RUN curl -sSL -o libssl1.0.0_1.0.2n-1ubuntu5.8_amd64.deb http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.13_amd64.deb
RUN dpkg -i libssl1.0.0_1.0.2n-1ubuntu5.8_amd64.deb
RUN rm libssl1.0.0_1.0.2n-1ubuntu5.8_amd64.deb

# we have a separate distribtest for netcoreapp3.1
ENV SKIP_NETCOREAPP31_DISTRIBTEST=1
# we have a separate distribtest for net5.0
ENV SKIP_NET50_DISTRIBTEST=1
