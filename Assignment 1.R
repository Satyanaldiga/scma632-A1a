data<-read.csv("C:\\Users\\SPURGE\\Desktop\\SCMA\\NSSO68.csv")

library(dplyr)
library(readr)
library(readxl)
library(tidyr)
library(ggplot2)
library(BSDA)
library(glue)

#FILTERING FOR MP
df=data%>%
  filter(state_1=="MP")

names(df)
head(df)
dim(df)

# Finding missing values
missing_info <- colSums(is.na(df))
cat("Missing Values Information:\n")
print(missing_info)

# Sub-setting the data
MPnew <- df %>%
  select(state_1, District, Region, Sector, State_Region, Meals_At_Home, ricepds_v, Wheatpds_q, chicken_q, pulsep_q, wheatos_q, No_of_Meals_per_day)

# Check for missing values in the subset
cat("Missing Values in Subset:\n")
print(colSums(is.na(MPnew)))

# Impute missing values with mean for specific columns
impute_with_mean <- function(column) {
  if (any(is.na(column))) {
    column[is.na(column)] <- mean(column, na.rm = TRUE)
  }
  return(column)
}
MPnew$Meals_At_Home <- impute_with_mean(MPnew$Meals_At_Home)


# Check for missing values after imputation
cat("Missing Values After Imputation:\n")
print(colSums(is.na(MPnew)))


# Finding outliers and removing them
remove_outliers <- function(df, column_name) {
  Q1 <- quantile(df[[column_name]], 0.25)
  Q3 <- quantile(df[[column_name]], 0.75)
  IQR <- Q3 - Q1
  lower_threshold <- Q1 - (1.5 * IQR)
  upper_threshold <- Q3 + (1.5 * IQR)
  df <- subset(df, df[[column_name]] >= lower_threshold & df[[column_name]] <= upper_threshold)
  return(df)
}

outlier_columns <- c("ricepds_v", "chicken_q")
for (col in outlier_columns) {
  MPnew <- remove_outliers(MPnew, col)
}


# Summarize consumption
MPnew$total_consumption <- rowSums(MPnew[, c("ricepds_v", "Wheatpds_q", "chicken_q", "pulsep_q", "wheatos_q")], na.rm = TRUE)


  # Summarize and display top and bottom consuming districts and regions
  summarize_consumption <- function(group_col) {
    summary <- MPnew %>%
      group_by(across(all_of(group_col))) %>%
      summarise(total = sum(total_consumption)) %>%
      arrange(desc(total))
    return(summary)
  }
  
  
  district_summary <- summarize_consumption("District")
  region_summary <- summarize_consumption("Region")
  
  cat("Top 3 Consuming Districts:\n")
  print(head(district_summary, 3))
cat("Bottom 3 Consuming Districts:\n")
print(tail(district_summary, 3))


cat("Region Consumption Summary:\n")
print(region_summary)


# Rename districts and sectors , get codes from appendix of NSSO 68th ROund Data
district_mapping <- c("21" = "Ujjain", "26" = "Indore", "03" = "Bhind")
sector_mapping <- c("2" = "URBAN", "1" = "RURAL")

MPnew$District <- as.character(MPnew$District)
MPnew$Sector <- as.character(MPnew$Sector)
MPnew$District <- ifelse(MPnew$District %in% names(district_mapping), district_mapping[MPnew$District], MPnew$District)
MPnew$Sector <- ifelse(MPnew$Sector %in% names(sector_mapping), sector_mapping[MPnew$Sector], MPnew$Sector)


# Test for differences in mean consumption between urban and rural
rural <- MPnew %>%
  filter(Sector == "RURAL") %>%
  select(total_consumption)

urban <- MPnew %>%
  filter(Sector == "URBAN") %>%
  select(total_consumption)

mean_rural <- mean(rural$total_consumption)
mean_urban <- mean(urban$total_consumption)

# Perform z-test
z_test_result <- z.test(rural, urban, alternative = "two.sided", mu = 0, sigma.x = 2.56, sigma.y = 2.34, conf.level = 0.95)


# Generate output based on p-value
if (z_test_result$p.value < 0.05) {
  cat(glue::glue("P value is < 0.05 i.e. {round(z_test_result$p.value,5)}, Therefore we reject the null hypothesis.\n"))
  cat(glue::glue("There is a difference between mean consumptions of urban and rural.\n"))
  cat(glue::glue("The mean consumption in Rural areas is {mean_rural} and in Urban areas its {mean_urban}\n"))
} else {
  cat(glue::glue("P value is >= 0.05 i.e. {round(z_test_result$p.value,5)}, Therefore we fail to reject the null hypothesis.\n"))
  cat(glue::glue("There is no significant difference between mean consumptions of urban and rural.\n"))
  cat(glue::glue("The mean consumption in Rural area is {mean_rural} and in Urban area its {mean_urban}\n"))
}


boxplot(MPnew$ricepds_v)



MPnew$total_consumption= 
  MPnew$ricepds_v+MPnew$Wheatpds_q+MPnew$chicken_q+MPnew$pulsep_q+MPnew$wheatos_q
 MPnew%>%
  + group_by(District)%>%
  + summarise(total=sum(total_consumption))%>%
  + arrange(-total,District)
