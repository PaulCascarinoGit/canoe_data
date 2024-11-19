library(shiny)
library(httr)
library(jsonlite)

# Charger la configuration client
client_secrets <- fromJSON("config/client_secrets.json")
client_id <- client_secrets$web$client_id
client_secret <- client_secrets$web$client_secret
token_uri <- client_secrets$web$token_uri
userinfo_uri <- client_secrets$web$userinfo_uri

# UI
ui <- fluidPage(
    titlePanel("Shiny + Keycloak Authentication"),
    textInput("username", "Username", ""),
    passwordInput("password", "Password", ""),
    actionButton("login", "Login"),
    textOutput("user_info"),
    textOutput("error_message")
)

# Serveur
server <- function(input, output, session) {
    observeEvent(input$login, {
        # Authentification auprès de Keycloak avec username et password
        res <- POST(
            token_uri,
            body = list(
                grant_type = "password",
                username = input$username,
                password = input$password,
                client_id = client_id,
                client_secret = client_secret,
                scope = "openid"  # Ajout du scope "openid"
            ),
            encode = "form"
        )
        
        if (http_error(res)) {
            output$error_message <- renderText({
                paste("Authentication failed:", content(res, "text"))
            })
        } else {
            token <- content(res, "parsed")
            
            # Récupérer les informations utilisateur
            userinfo_res <- GET(
                userinfo_uri,
                add_headers(Authorization = paste("Bearer", token$access_token))
            )
            
            if (http_error(userinfo_res)) {
                output$error_message <- renderText({
                    paste("Failed to retrieve user info:", content(userinfo_res, "text"))
                })
            } else {
                userinfo <- content(userinfo_res, "parsed")
                output$user_info <- renderText({
                    paste("Welcome,", userinfo$name)
                })
                output$error_message <- renderText("")
            }
        }
    })
}

# Lancer l'application
shinyApp(ui, server)
