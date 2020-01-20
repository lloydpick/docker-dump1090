FROM alpine:3.11.3 as base

RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories
RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk add --no-cache tini librtlsdr@testing libusb ncurses-libs


FROM base as build

RUN apk add --no-cache curl ca-certificates coreutils make gcc pkgconf libc-dev
RUN apk add --no-cache libusb-dev ncurses-dev librtlsdr-dev@testing

ARG DUMP1090_VERSION=v3.7.1

RUN mkdir /dump1090
WORKDIR /dump1090

RUN curl -L --output 'dump1090-fa.tar.gz' "https://github.com/flightaware/dump1090/archive/${DUMP1090_VERSION}.tar.gz"
RUN tar -xvf dump1090-fa.tar.gz --strip-components=1

RUN make BLADERF=NO DUMP1090_VERSION="${DUMP1090_VERSION}"
RUN make test


FROM base

COPY --from=build /dump1090/dump1090 /usr/local/bin/dump1090

EXPOSE 30002/tcp
EXPOSE 30005/tcp

ENTRYPOINT ["tini", "--", "nice", "-n", "-5", "dump1090", "--net", "--net-bind-address", "0.0.0.0", "--debug", "n", "--mlat", "--net-heartbeat", "5", "--quiet", "--stats-every", "60"]
