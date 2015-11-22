# this scrit is a draft to generate the final result table ate report
# performing the analysis

# loading the result dataset
load("./result/summary.rdata")

# selecting only data from attributes study
columns <- c("feature.name","classification.levels","business.category",
             "algorithm","accuracy")


data <-  fitSummary[fitSummary$cycle.name=="attribute.analysis.400kdataset" &
                      fitSummary$algorithm=="MAXENT" &
                      fitSummary$business.category=="Restaurants" &
                      fitSummary$term.size > 20000,columns]

library(reshape2)
d <- melt(data, id=columns[1:4])
f <- paste(paste(columns[1:3],collapse="+"),columns[4],sep="~")
d <- dcast(d, as.formula(f) , mean)

library(dplyr)
d <- dplyr::arrange(d, desc(MAXENT), desc(SVM))


###################

load("./result/summary.rdata")
data <-  fitSummary[fitSummary$cycle.name=="attribute.analysis.400kdataset" &
                      fitSummary$algorithm=="MAXENT" &
                      fitSummary$business.category=="Restaurants" &
                      fitSummary$term.size > 20000,c("feature.name","classification.levels","classification.names")]


library(htmlTable)
?htmlTable

########################3

install.packages("DiagrammeR")

library(DiagrammeR)


grViz("
digraph boxes_and_circles {

  # a 'graph' statement
  graph [overlap = true, fontsize = 10,rankdir=LR]

  # several 'node' statements
  node [shape = box,
        fontname = Helvetica]
  Giul; B; C; 

  Giul -> B -> C

}
")