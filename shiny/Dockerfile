FROM rocker/shiny

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y libcurl4-openssl-dev libssl-dev

# Installer les packages R nécessaires
RUN R -e "install.packages(c('shiny', 'httr', 'jsonlite'), repos = 'https://cloud.r-project.org/')"

# Copier les fichiers de l'application
COPY app.R /srv/shiny-server/
COPY config/client_secrets.json /srv/shiny-server/config/client_secrets.json
