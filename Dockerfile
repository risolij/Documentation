FROM nixos/nix:latest AS builder

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /app

COPY . .

RUN nix build

FROM debian:bookworm-slim

COPY --from=builder /nix/store /nix/store
COPY --from=builder /app/result /app/result

ENV PATH="/app/result/bin:${PATH}"

WORKDIR /app

COPY docs /app/docs
COPY zensical.toml /app/zensical.toml
COPY site /app/site

EXPOSE 8000

ENTRYPOINT ["zensical"]
CMD ["serve", "--dev-addr", "0.0.0.0:8000"]
