FROM perl:5.40-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      cpanminus \
      build-essential \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && cpanm --notest Plack Starman

WORKDIR /app
COPY app.psgi .

EXPOSE 8080
CMD ["plackup", "-s", "Starman", "-p", "8080", "app.psgi"]
