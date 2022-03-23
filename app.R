library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyauthr)

# I. UI ###########################################################

ui <- dashboardPage(
    ## I.1. DASHBOARD HEADER ##########################################
    
    dashboardHeader(),
    
    
    ## I.2. DASHBOARD SIDEBAR #########################################
    
    dashboardSidebar(

        collapsed = FALSE,
    
    #### set the sidebar to be collapsed by default and to be expanded
    #### after user authorization
    ####    observe({
    ####        if(credentials()$user_auth) {
    ####            shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    ####        } else {
    ####            shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    ####        }
    ####    })
        
        div(htmlOutput("welcome"), style = "padding: 20px"),
        sidebarMenu(
            menuItem("View Tables", tabName = "view_table", icon = icon("search")),
            menuItem(
                "Create Tables",
                tabName = "create_table",
                icon = icon("plus-square")
            ),
            menuItem(
                "Update Tables",
                tabName = "update_table",
                icon = icon("exchange-alt")
            ),
            menuItem("Insert Entries", tabName = "insert_value", icon = icon("edit")),
            menuItem(
                "Delete Tables",
                tabName = "del_table",
                icon = icon("trash-alt")
            ),
            menuItem("About", tabName = "about", icon = icon("info-circle"))
        )
    ),
    
    ## I.3. DASHBOARD BODY #######################################
    
    dashboardBody(
        dashboardBody(
            tabItems(
                tabItem(tabName = "view_table", uiOutput("tab1UI")),
                tabItem(tabName = "del_table", uiOutput("tab2UI")),
                tabItem(tabName = "update_table", uiOutput("tab3UI")),
                tabItem(tabName = "create_table", uiOutput("tab4UI")),
                tabItem(tabName = "insert_value", uiOutput("tab5UI")),
                tabItem(tabName = "about", uiOutput("tab6UI"))
            )
        ),
        
        
    )
)

# SERVER ###########################################################

server <- function(input, output, session) {
    
    user_base <- data.frame(
        username = c("user1", "user2"),
        password = c("pass1", "pass2"), 
        password_hash = sapply(c("pass1", "pass2"), sodium::password_store), 
        permissions = c("manager", "admin")
    )
    
    logout_init <- callModule(shinyauthr::logout, 
                              id = "logout", 
                              reactive(credentials()$user_auth))
    
    credentials <- callModule(shinyauthr::login, 
                              id = "login", 
                              data = user_base,
                              user_col = username,
                              pwd_col = password_hash,
                              sodium_hashed = TRUE,
                              log_out = reactive(logout_init()))
    
    output$user_table <- renderUI({
        if(credentials()$user_auth) return(NULL)
        fluidRow(column(4,
                        p("Please use the usernames and passwords ...", 
                          class = "text-center", style = "font-size: 15px;"),
                        br(),
                        renderTable({user_base[, -3]}), offset = 4
        )
        )
    })
    
    output$tab3UI <- renderUI({
        fluidPage(
            fluidRow(
                box(width = 12, collapsible = TRUE, title = "Note:", "")
            ),
            fluidRow(
                box(title = "Rename Table", width = 4, solidHeader = TRUE, status = "primary",
                    selectInput(),
                    wellPanel(
                        textInput(),
                        actionButton())
                ),
                box(title = "Rename Column", width = 4, solidHeader = TRUE, status = "primary",
                    selectInput(),
                    wellPanel()
                ),
                box(title = "Add Column", width = 4, solidHeader = TRUE, status = "primary",
                    selectInput(),
                    wellPanel()
                )
            )
        )
    })
    
    loginUI(id = "login", 
            title = "Please log in", 
            user_title = "User Name",
            pass_title = "Password", 
            login_title = "Log in",
            error_message = "Invalid username or password!",
            additional_ui = NULL)
    
    logoutUI(id = "logout", 
             label = "Log out", 
             icon = NULL, 
             class = "btn-danger",
             style = "color: white;")
    
}

shinyApp(ui, server)
