FROM nixos/nix:latest AS builder

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /app

COPY . .

RUN nix build
RUN ./result/bin/zensical build

FROM debian:bookworm-slim

COPY --from=builder /nix/store /nix/store
COPY --from=builder /app/result /app/result
COPY --from=builder /app/site /app/site
COPY --from=builder /app/zensical.toml /app/zensical.toml
COPY --from=builder /app/docs /app/docs

ENV PATH="/app/result/bin:${PATH}"

WORKDIR /app

EXPOSE 8000

ENTRYPOINT ["zensical"]
CMD ["serve", "--dev-addr", "0.0.0.0:8000"]
