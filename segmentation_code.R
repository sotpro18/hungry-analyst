library(data.table)
library(ggplot2)

# couldn't read greek characters - run this only once
# Sys.setlocale(category = "LC_ALL", locale = "Greek")

# read the dataset
dt <- fread('/Users/Sotiris/Desktop/data_input.csv', sep=',', encoding = 'UTF-8')

# Find what time each order happened
# Find what day of the weak each order happened - 0 denotes Sundays
dt[, ':=' (Time = hour(submit_dt_GR),
           DayOfWeek = as.POSIXlt(submit_dt_GR)$wday)]

# Get metrics per user
# Exclude orders with basket <= 1
per_user <- dt[basket > 1, .(Orders = .N,
                             AverageValue = mean(basket),
                             WeekendOrdersRatio = sum(ifelse(DayOfWeek == 0 | DayOfWeek == 6 | (DayOfWeek == 5 & Time >= 19) | (DayOfWeek == 1 & Time <= 4), 1, 0)) / .N,
                             MorningtoEveningOrdersRatio = sum(ifelse(Time >= 6 & Time < 18, 1, 0)) / .N), by = .(user_id)]

# Segment only users with 3 or more orders
per_user_above_threshold <- per_user[Orders >= 3, ]

# Keep the rest of the users somewhere separately so that we can get some metrics on them later if needed
per_user_below_threshold <- per_user[Orders < 3, ]
# Create a fifth cluster "unclassified" with these users so that we can track them separately as a group later
per_user_below_threshold[, ':=' (Cluster = as.factor(5), ClusterName = 'Unclassified')]

# plot the variables against each other
# pairs(per_user_above_threshold[, .(Orders, AverageValue, WeekendOrdersRatio, MorningtoEveningOrdersRatio)])

# scale the data since they are of different magnitude
kmeansdataset <- copy(per_user_above_threshold)
cols <- c('Orders', 'AverageValue', 'WeekendOrdersRatio', 'MorningtoEveningOrdersRatio')
kmeansdataset[, (cols) := lapply(.SD, scale), .SDcols=cols]

#create the model and also set the seed so that we always get the same output
set.seed(1)
kmModel <- kmeans(kmeansdataset[, .(Orders, AverageValue, WeekendOrdersRatio, MorningtoEveningOrdersRatio)], centers = 4, nstart = 100)

#add the clusters to the dataset
kmeansdataset[, Cluster := as.factor(kmModel$cluster)]
per_user_above_threshold[, Cluster := as.factor(kmModel$cluster)]

# Get some metrics to describe the clusters
# a <- per_user_above_threshold[, .(.N, Orders = mean(Orders), Value = mean(AverageValue), WeekendRatio = mean(WeekendOrdersRatio), MorningtoEveningOrdersRatio = mean(MorningtoEveningOrdersRatio)), by = .(Cluster)]
# setorder(a, N)
# a

# since we have set the seed earlier, the same cluster ids appear so we can name them here
per_user_above_threshold[, ClusterName := ifelse(Cluster == 1, 'Saved by efood', ifelse(Cluster == 2, 'Weekenders', ifelse(Cluster == 3, 'The Breakfast Club', 'Evening Value')))]

#plot the data coloured by cluster - orders against average value
ggplot(per_user_above_threshold, aes(Orders, AverageValue, color = per_user_above_threshold$ClusterName)) + geom_point()


# write the output - also add in the output the "unidentified" clusters - users with less than 3 orders
fwrite(rbindlist(l = list(per_user_above_threshold, per_user_below_threshold)), '/Users/Sotiris/Desktop/clusters.csv')