import pandas as pd
print(pd.__version__)

# General comments: Add a more clear structure to the code. I would suggest first creating the dfs you will use, city names and california housing, then doing some primary summary stats, and then continuing with some data manipulation
# (if area > 50 & name start with San, etc.)
# Also, consider naming your columns in Pandas without whitespaces (use _ instead). This way you could also use the dot notation that might be handy in some cases (i.e. df.column instead of df['column']).
# Using only lowercase in code-column names is considered good practice as well, you can capitalize columns if needed for a presentation later.

# No need to specify lists as Pandas series, this occurs automatically when creating a df object
# Also doesn't affect speed
city_names = ['San Francisco', 'San Jose', 'Sacramento']
population = [852469, 1015785, 485199]
area_sqm = [46.87, 176.53, 97.92]  # Cleaner to introduce this here. The name you chose was too verbose, sqm is enough

# use df in name, dataframe is too verbose. Also start with df, easier to filter when writing code and auto-completing, just write df and all dataframe names pop-up, easier for reader to see this is df since term is in the beginning.
# Don't create a dataframe just to .describe() it (without actually printing it) and then re-create it again!
# Create a dataframe, and if needed print it with .describe()
df_cities = pd.DataFrame({'City name': city_names,
                                     'Population': population,
                                     'Area miles': area_sqm})  # Area implies square, so area miles is sufficient.

# no need to specify the delimeter in this case since commas are assumed by default
df_california_housing = pd.read_csv("https://download.mlcc.google.com/mledu-datasets/california_housing_train.csv")

# When printing summary stats show all columns! (Change None to int for required number of columns, None = all)
# I've added some "titles" to make my life easier when checking the data, but that's just a personal taste
pd.set_option('display.max_columns', None)
print("\nCALIFORNIA HOUSING\n", df_california_housing.describe())
print("\nCITIES\n", df_cities.describe())

# Do you need to check head() if you've printed describe? Perhaps consider shuffling the data
# print(df_california_housing.head())

# Why are you re-introducing the same df, under a different name?
# cities = pd.DataFrame({ 'City name': city_names, 'Population': population })

# Don't see the reason to print separately each column. Can print perhaps the whole df, after all there's just one more column!
# print(cities['City name'])
# print(cities['Population'])
# Or in bigger dfs, just print both columns together
print("\nCITIES\n", df_cities[["City name", "Population"]])


# Introduced this above, not needed
# cities['Area square miles'] = pd.Series([46.87, 176.53, 97.92])

# I dislike very verbose column names, sorry
# Consider .lower() all city names before searching for "san", you want to be sure you won't miss cities due to typos in caPitAlIzaTioN.
# No need for a lambda expression and apply here, with .str you can directly check the string values of a column
df_cities['wide and saint name'] = (df_cities['Area miles'] > 50) & (df_cities['City name'].str.startswith('San'))

# I don't see the point of this second column, since this should only be resolved to true for one row!
# df_cities['Is san francisco'] = (df_cities['City name'] == 'San Francisco')
print("\nCITIES\n", df_cities)

# Is there a reason you are reindexing? You seem to just want to order the df alphabetically. Just sortby and
# assuming you want to continue with the sorted df, reset the index as well.
# df_cities.reindex([2, 0, 1])
df_cities.sort_values('City name', inplace=True)
df_cities.reset_index(drop=True, inplace=True)  # drop implies that the old index is not kept as column
print("\nCITIES\n", df_cities)
