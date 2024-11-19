postgres:
  image: postgres:latest
  environment:
    - POSTGRES_USER=shiny_user
    - POSTGRES_PASSWORD=shiny_password
    - POSTGRES_DB=shiny_db
  volumes:
    - ./postgres/init:/docker-entrypoint-initdb.d
  ports:
    - "5432:5432"
