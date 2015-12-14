library(shiny)
library(stringr)
library(stats)
df.test <- data.frame(a=1,b=2)
shinyServer(function(input, output, session) {
  output$hideScript <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    if("key" %in% names(query)){
      "<script>$('#keydiv').css('display','none');</script>"
    } else {
      "<script>$('#tablediv').css('display','none');$('#keydiv').css('display','block');</script>"
    }
  })
  
  output$xcols <- renderUI({
    query <- parseQueryString(session$clientData$url_search)
    if("key" %in% names(query)){
      selectInput('xcol', 'X Variable', names(df.test))
    } else {
    }
  })
  
  output$ycols <- renderUI({
    query <- parseQueryString(session$clientData$url_search)
    if("key" %in% names(query)){
      selectInput('ycol', 'Y Variable', names(df.test), selected=names(df.test)[[2]])
    } else {
    }
  })
  
  output$tcols <- renderUI({
    query <- parseQueryString(session$clientData$url_search)
    if("key" %in% names(query)){
      selectInput('tcol', 'Target Variable', names(df.test), selected=names(df.test)[[ncol(df.test)]])
    } else {
    }
  })
  
  output$tabletest <- renderDataTable(df.test)
  # Combine the selected variables into a new data frame
  # begin
  selectedData <- reactive({
    df.test[, c(input$xcol, input$ycol)]
  })
  
  targetData <- reactive({
    a <- levels(df.test[, c(input$tcol)])
    b <- df.test[, c(input$tcol)]
    for(i in 1:length(a)){
      b <- ifelse(b==a[[i]],i,b)
    }
    b
  })

  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })
  
  output$plot1 <- renderPlot({
    query <- parseQueryString(session$clientData$url_search)
    if("key" %in% names(query)){
      par(mar = c(5.1, 4.1, 0, 1))
      plot(selectedData(),
           col = clusters()$cluster,
           pch = targetData()+14, cex = 2)
      # pch = 20
      points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
    } else {
    }
  })
  # end
  
  api_url <- session$registerDataObj( 
    name   = 'api', # an arbitrary but unique name for the data object
    data   = list(), # you can bind some data here, which is the data argument for the
    # filter function below.
    filter = function(data, req) {
      # print(ls(req))  # you can inspect what variables are encapsulated in this req
      # environment
      if (req$REQUEST_METHOD == "GET") {
        # handle GET requests
        query <- parseQueryString(req$QUERY_STRING)
        
      } 
      
      if (req$REQUEST_METHOD == "POST") {
        # handle POST requests here
        reqInput <- req$rook.input
        
        # data must be one line and must be the form of http://www.yoheim.net/blog.php?q=20120611
        strs <- paste0("?key=T")
        datastr <- reqInput$read_lines(1)
        str_split(datastr, "\\&")
        data <- parseQueryString(datastr)
        for(i in 1:(length(data) - 1)){
          data[[i]] <- str_split(data[[i]],",")[[1]]
          data[[i]] <- as.numeric(data[[i]])
        }
        data[[length(data)]] <- str_split(data[[length(data)]],",")[[1]]
        df.test <<- as.data.frame(data)
        df.test[,ncol(df.test)] <<- factor(df.test[,ncol(df.test)])
        print(df.test)
        colnames(df.test) <<- names(data)
        buf <- paste0(
          '<HEAD><META HTTP-EQUIV="Refresh" CONTENT="0; URL=http://127.0.0.1:7458/',strs,
          '" /></HEAD>')
          
        shiny:::httpResponse(
          status=200, content_type='text/html', content=buf
        )
      }          
    }
  )
  
  # because the API entry is UNIQUE, we need to send it to the client
  # we can create a custom pipeline to convey this message
  session$sendCustomMessage("api_url", list(url=api_url))
})
