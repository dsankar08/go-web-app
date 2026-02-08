#Multi-stage Docker file 
#First stage for build

FROM golang:1.26rc3-bookworm AS base

WORKDIR /app

COPY go.mod .

RUN go mod download

COPY . .

RUN go build -o main .

#Second stage

# Distroless nonroot image 
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

#Copying the binary and static files from the base stage
COPY --from=base /app/main .

COPY --from=base /app/static ./static

EXPOSE 8080

#Healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD curl -f http://localhost:8080/ || exit 1

CMD ["./main"]