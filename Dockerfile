FROM nixos/nix:latest AS builder

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /app
COPY . .

RUN nix build .

FROM alpine:latest
COPY --from=builder /app/result/bin/zensical /usr/local/bin/zensical

WORKDIR /docs
EXPOSE 8000
ENTRYPOINT ["zensical"]

CMD ["serve", "--addr", "0.0.0.0:8000"]
