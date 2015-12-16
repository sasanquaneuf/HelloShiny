library(shiny)
library(stringr)
library(arules)
df.test <- data.frame(a=1,b=2)
setTimeLimit(5,5)
shinyServer(function(input, output, session) {
  output$hideScript <- renderText({
    query <- parseQueryString(session$clientData$url_search)
    if("key" %in% names(query)){
      "<script>$('#keydiv').css('display','none');</script>"
    } else {
      "<script>$('#tablediv').css('display','none');$('#keydiv').css('display','block');</script>"
    }
  })
  
  output$tabletest <- renderDataTable(getRule())
  
  getRule <- function(){
    tryCatch({
      setTimeLimit(5,5)
      d <- apriori(as(df.test[[2]],"transactions"), parameter=list(support=input$support, confidence=input$confidence))
      setTimeLimit(Inf,Inf)
    },error=function(e){
      setTimeLimit(Inf,Inf)
      stop(e)
    })
    e <- as(d,"data.frame")
    e$LHS <- str_replace_all(e$rules,"=>.+","")
    e$RHS <- str_replace_all(e$rules,".+=>","")
    e
  }
  
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
        for(i in 1:length(data)){
          data[[i]] <- str_split(data[[i]],",")
          data[[i]] <- lapply(data[[i]], function(d){str_split(d,"!")})[[1]]
        }
        df.test <<- data
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
