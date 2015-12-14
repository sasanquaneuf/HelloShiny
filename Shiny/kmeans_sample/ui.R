library(shiny)
shinyUI(fluidPage(
  singleton(tags$head(HTML(
    '
    <script type="text/javascript">
    $(document).ready(function() {
      // creates a handler for our special message type
      Shiny.addCustomMessageHandler("api_url", function(message) {
        // set up the the submit URL of the form
        var shiny_test = document.getElementById("shiny_test")
        shiny_test.innerHTML = "http://127.0.0.1:7458/" + message.url;
      });
    })
    </script>
    '
  ))),
  uiOutput("hideScript"),
  div(id="keydiv",style="display:none;",
    HTML("<span id='shiny_test'></span>")
  ),
  div(id="tablediv",
      uiOutput("xcols"),
      uiOutput("ycols"),
      uiOutput("tcols"),
      numericInput('clusters', 'Cluster count', 3,
                   min = 1, max = 9),
      plotOutput('plot1')
      # dataTableOutput("tabletest")
  )
))