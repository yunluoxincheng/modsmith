# Starter sandbox image for generated Forge 1.20.1 builds.
# Must be tested and hardened before production.
FROM eclipse-temurin:17-jdk-jammy
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates unzip coreutils \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
CMD ["bash", "-lc", "./gradlew --no-daemon clean build"]
