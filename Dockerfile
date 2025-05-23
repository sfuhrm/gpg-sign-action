# Container image that runs your code
FROM alpine:3.21.3

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# install needed programs
RUN apk add gpg gpg-agent

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
