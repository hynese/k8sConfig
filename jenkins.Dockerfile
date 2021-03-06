# build with:
# docker build -t localhost:32000/jenkins-with-docker -f jenkins.Dockerfile .

# push with:
# docker push localhost:32000/jenkins-with-docker

# start with:
# microk8s.kubectl apply -f deployment-jenkins.yaml

FROM jenkins/jenkins:lts
#FROM jenkins/jenkins:lts-alpine

USER root
# suppress key warnings:
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Prerequisites:
RUN apt-get update
RUN apt-get install -y curl software-properties-common telnet zip vim apt-transport-https golang
# envsubst and jq:
RUN apt-get install -y gettext-base jq
# yq:
ENV GOPATH=/usr
RUN go get gopkg.in/mikefarah/yq.v2
RUN ln -s /usr/bin/yq.v2 /usr/bin/yq
#RUN chmod +x /usr/bin/yq

# Install node and npm (building JS apps):
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update
RUN apt-get install -y nodejs

# Adding Docker (building images):
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN cat /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli
#it is very important to adjust the container docker's gid to be the same as the host docker gid
RUN usermod -aG docker jenkins

# Install kubectl (for deployment):
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# drop back to the regular jenkins user - good practice
USER jenkins
