FROM gliderlabs/alpine:edge
MAINTAINER "Guigo2k" <hello@guigo.pw>

ADD np-cli /usr/local/np-cli
RUN /usr/local/np-cli/np setup

EXPOSE 80 443
ENTRYPOINT ["/usr/bin/np"]
CMD ["start"]
