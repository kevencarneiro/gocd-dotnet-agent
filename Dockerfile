FROM mcr.microsoft.com/dotnet/sdk:5.0

# GoCD agent needs the jdk and git/svn/mercurial...
RUN apt-get update && apt-get install -y --no-install-recommends \
        gnupg git software-properties-common \
    && rm -rf /var/lib/apt/lists/* 
RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN apt-get update \
    && apt-get install -y --no-install-recommends adoptopenjdk-13-hotspot \
    && rm -rf /var/lib/apt/lists/* 

# Add a user to run the go agent
RUN addgroup go
RUN adduser go --ingroup go --home /go --disabled-password --system

# download tini to ensure that an init process exists
ADD https://github.com/krallin/tini/releases/download/v0.14.0/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# ensure that the container logs on stdout
ADD log4j.properties /go/log4j.properties
ADD log4j.properties /go/go-agent-log4j.properties

ADD go-agent /go-agent
RUN chmod 755 /go-agent

# Run the bootstrapper as the `go` user
USER go
CMD /go-agent