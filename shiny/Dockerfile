# Utilise une image de base pour R et Shiny
FROM rocker/shiny:4.3.1

RUN R -e "install.packages('httr')"
RUN R -e "install.packages('shiny')"

# Copie l'application Shiny dans le conteneur
COPY . /srv/shiny-server/

# Expose le port 3838 pour accéder à l'application
EXPOSE 3838

# Commande pour démarrer l'application Shiny
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host = '0.0.0.0', port = 3838)"]
