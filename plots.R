library(tidyverse)
library(readr)
library(viridis)
library(scales)
library(highcharter)
library(htmlwidgets)
options(browser = "/usr/bin/firefox")

mapdata <- get_data_from_map(download_map_data("custom/africa"))

african_data <- read_csv("../../african_data.csv")
african_data$Date <- as.Date(as.character(african_data$Date), format = "%Y-%m-%d")

names(african_data)[27] <- "Contact_Tracing"

testing_data <- african_data[, names(african_data) %in% c("Date", "CountryName", "Contact_Tracing", "CountryCode")]

testing_data <- testing_data[complete.cases(testing_data), ]

testing_data$CountryName <- factor(testing_data$CountryName,levels=rev(unique(testing_data$CountryName)))

## testing_data <- testing_data[testing_data$Date > "2020-02-14", ]

testing_data <- testing_data[testing_data$CountryName != "France",]

## just get max------------------
just_testing_data_latest <- testing_data %>% 
    group_by(CountryName) %>%
    arrange(Date) %>%
    mutate(max_testing_data = max(unique(Date)))

just_testing_data_latest <- just_testing_data_latest[(just_testing_data_latest$Date == just_testing_data_latest$max_testing_data), ]

names(just_testing_data_latest)[2] <- "iso-a3"

## graphic

x <- c("Country", "Date", "Contact Tracing")
y <- c("{point.CountryName}" , "{point.Date}", "{point.Contact_Tracing}")

tltip <- tooltip_table(x, y)

carmine <- "#960018"
dark_midnight_blue <- "#003366"
white <- "#FFFFFF"
milken <- "#0066CC"
milken_red <- "#ff3333"

## map cases per of pop
contact_tracing_map <- hcmap("custom/africa", data = just_testing_data_latest, value = "Contact_Tracing",
      joinBy = c("iso-a3"), name = "Contact Tracing",
      borderColor = "#FAFAFA", borderWidth = 0.1) %>%
      hc_tooltip(useHTML = TRUE, headerFormat = "", pointFormat = tltip) %>%
    hc_legend(align = "center", layout = "horizontal", verticalAlign = "middle", x = -160, y= 120, valueDecimals = 0) %>%
    hc_colorAxis(minColor = "#e2e2e2", maxColor = milken,
             type = "linear")


# contact_tracing_map

## Save vis
saveWidget(contact_tracing_map, file="contact_tracing_map.html")
