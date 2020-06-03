
library(shiny)

shinyUI(pageWithSidebar(
  headerPanel(h2('Expected Response Time for Concurrency Level')),  
  
  sidebarPanel(
    
    sliderInput('nServers', label = 'Number of Workers (N):',
                min = 1, max = 32, value = 1),
    
    sliderInput('processingMs', label = 'Processing time in ms:',
                min = 1, max = 500, value = 100),
    
    helpText(strong('Zoom in'), ' by selecting a region in the top chart then ',
             'double-clicking within the selection. All four charts will zoom', 
             'to the selected range'),
    
    helpText(strong('Reset'),   ' to the default zoom by double clicking in the top chart.')
    , 

   helpText('Thanks to the following resources:'),
   helpText(
            a(href='http://timwise.github.io/queue-calculator-slides/#1',
              'Comparing the Response Time of Three Simple Queueing Systems'
            ),
            ', An analysis of three queuing systems and the inspiration for our shiny application.'
   ),
    helpText('-',
             a(href='http://cran.r-project.org/web/packages/queueing/queueing.pdf',
               'queueing: Analysis of Queueing Networks and Models'),
             ', An R package by Pedro Canadilla for solving queueing networks.',
             'We used it in our shiny application.'
    )
  ),
  
  mainPanel(
    
       plotOutput('rspTimeChart', height = 350, width = 400, 
                  dblclick = 'rspTimeChart.dblClick',     
                  brush = brushOpts(
                    id = 'rspTimeChart.brush',
                    resetOnNew = TRUE
                  )  
       )

  ) 
)) 
