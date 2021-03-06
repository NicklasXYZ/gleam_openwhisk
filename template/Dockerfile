# First build stage
FROM erlang:24-alpine as builder

MAINTAINER NicklasXYZ

WORKDIR /usr/src

ENV GLEAM_VERSION v0.16.1

# Install Rebar3 and Gleam 
RUN wget https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3 && \
    cp rebar3 /usr/bin/rebar3 && \
    rm -f rebar3 && \
    wget https://github.com/gleam-lang/gleam/releases/download/${GLEAM_VERSION}/gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    tar zxf gleam-${GLEAM_VERSION}-linux-amd64.tar.gz && \
    chmod +x gleam && \
    cp gleam /usr/bin/gleam && \
    rm -f gleam gleam-${GLEAM_VERSION}-linux-amd64.tar.gz

# Copy function files and folders into the container
COPY . .
# Compile Gleam code and create a release 
RUN rebar3 release

# Final build stage
FROM erlang:24-alpine as app

WORKDIR /home/app

# Copy Gleam release from 'builder' build stage to current 'app' build stage   
COPY --from=builder /usr/src/_build/default/rel/gleam_openwhisk .
# Make the release executable
RUN chmod +x /home/app/bin/gleam_openwhisk

# Add non root user
RUN addgroup -S app && adduser -S -g app app \
    && mkdir -p /home/app \
    && chown -R app /home/app

USER app

EXPOSE 8080

# Start the elli webserver and leave the process in the foreground
CMD ["/bin/sh", "-lc", "/home/app/bin/gleam_openwhisk foreground"]
