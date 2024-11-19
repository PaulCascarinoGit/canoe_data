FROM rocker/shiny

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Installer les packages R nécessaires
RUN R -e "install.packages(c('httr', 'jsonlite', 'DBI', 'RPostgres', 'shiny'))"

# Copier les fichiers de l'application
COPY app.R /srv/shiny-server/
COPY config/client_secrets.json /srv/shiny-server/config/client_secrets.json
