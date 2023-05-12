#!/usr/bin/env Rscript
# derived from gpt4
# both files should have row and column names
library(argparse)
library(ggplot2)


# Parse command line arguments
parser <- ArgumentParser()
parser$add_argument("file1", help="Path to the first data file")
parser$add_argument("file2", help="Path to the second data file")
args <- parser$parse_args()


# Read data from files
data1 <- read.table(args$file1, header=TRUE, row.names=1)
data2 <- read.table(args$file2, header=TRUE, row.names=1)
print(head(data1))
# Calculate ellipse parameters
data1$radius1 <- abs(data1[,3] - data1[,2]) / 2
data2$radius1 <- abs(data2[,3] - data2[,2]) / 2

# Combine data into one data frame
data <- data.frame(estimate1 = data1[,1],
                   estimate2 = data2[,1],
                   radius1 = data1$radius1,
                   radius2 = data2$radius1)

# Calculate limits to include all ellipses
xylim <- c(min(c(data1[,2], data2[,2])), max(c(data1[,3], data2[,3])))


# Create an empty ggplot
p <- ggplot() +
  coord_cartesian(xlim=xylim, ylim=xylim, expand=FALSE) +
  xlab("CNN CPI") +
  ylab("Bayesian HPD") +
  ggtitle("Scatter plot of estimates with uncertainty ellipses")

p <- p + geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed")

# Add ellipses to the plot
for (i in 1:nrow(data)) {
  t <- seq(0, 2*pi, length.out=100)
  df <- data.frame(
    x = data$estimate1[i] + data$radius1[i] * cos(t),
    y = data$estimate2[i] + data$radius2[i] * sin(t)
  )
  p <- p + geom_polygon(data=df, aes(x=x, y=y), fill=NA, color='black')
}


# Save the plot to a PDF file
ggsave("scatterplot.pdf", plot = p, width = 10, height = 7)
