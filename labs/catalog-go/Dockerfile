FROM golang:1.12 as builder
WORKDIR /go/src/app
COPY . /go/src/app

RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -gcflags "-N -l" -ldflags="-compressdwarf=false" -o catalog-go .

FROM quay.io/crio/alpine:3.9
COPY --from=builder /go/src/app /app
WORKDIR /app
EXPOSE 8080
CMD ["/app/catalog-go"]
