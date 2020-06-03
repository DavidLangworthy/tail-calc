
library(shiny)

library(scales)
library(ggplot2)
library(Cairo)
library(queueing)

rho     <- seq (0.01, 0.99, by = 0.01)
nPoints <- length(rho)

yMax <- 1
yBreaks <- seq(0, 128, by = 2)
yLabels <- sprintf('%sx', yBreaks)
xBreaks <- seq(0, 1, by = 0.2)

formatYLabel <- function(l) {
  sprintf('%sx', l)
}



shinyServer(
  function(input, output) {
    
    # React to changes in the Number of Servers 
    #
    N <- reactive({ input$nServers })
    
    processing_s <- reactive({ input$processingMs }/1000)

    # Create the queue networks for each of the three systems
    # 
    btQueue <- reactive({ QueueingModel(NewInput.MMC(lambda =   N() * rho / processing_s(), mu = 1/processing_s(), c = N())) })

    # Watch for zoom actions in chart
    # 
    selectedRange <- reactiveValues(x = c(0, 1), 
                                    y = c(0, yMax))
    observeEvent(
      input$rspTimeChart.dblClick, {
        
        b <- input$rspTimeChart.brush
        
        if (!is.null(b)) {
          selectedRange$x <- c(b$xmin, b$xmax)
          selectedRange$y <- c(b$ymin, b$ymax)
          
        } else {
          selectedRange$x <- c(0, 1)
          selectedRange$y <- c(0, yMax)
        }
      }
    )
    
    # Chart Response Time
    #
    output$rspTimeChart<- renderPlot({ 
      
      rspData <- 
        rbind (
               data.frame(util= rho, rsp = processing_s(), qtype = 'Processing'), 
               data.frame(util= rho, rsp = processing_s() + Wq(btQueue())*processing_s(), qtype = 'Mean'), 
               data.frame(util= rho, rsp = processing_s() +Wq(btQueue())*processing_s() + 2*sqrt(VT(btQueue()))*processing_s(), qtype = '95%'), 
               data.frame(util= rho, rsp = processing_s() +Wq(btQueue())*processing_s() + 3*sqrt(VT(btQueue()))*processing_s(), qtype = '99.9%')
        )
      
      g <- 
        ggplot(
          data=rspData,
          aes(y = rsp, 
              x = util, 
              colour = qtype)) +  
        ggtitle(expression(paste('Response time ',italic('hockey sticks'),' as load increases'))) +
        labs(y      = 'Relative Response Time', 
             x      = 'System Utilization',
             colour = '') +
        geom_line(size = 0.75) +
        coord_cartesian(xlim = selectedRange$x, 
                        ylim = selectedRange$y) + 
        theme(plot.title      = element_text(size = 16, hjust = 0), 
              axis.title.x    = element_text(size = 12, colour = 'grey50'),
              axis.text.x     = element_text(size = 12, colour = 'grey50'),
              axis.title.y    = element_text(size = 12, colour = 'grey50'),
              axis.text.y     = element_text(size = 12, colour = 'grey50'),
              legend.position   = 'top',
              legend.title      = element_blank(),
              legend.text       = element_text(size = 14),
              legend.key        = element_rect(fill = 'transparent'),
              legend.background = element_rect(fill = 'transparent')
        )
      g
    })
    
  } 
) 
    