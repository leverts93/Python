import codecademylib3
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
print(ad_clicks.head())

#which platform getting the most views
print(ad_clicks.groupby('utm_source').user_id.count().reset_index())

#checking if timestamps are null
ad_clicks['is_click'] = ~ad_clicks.ad_click_timestamp.isnull()

#percent of people who clicked on ads from each source
clicks_by_source = ad_clicks.groupby(['utm_source', 'is_click']).user_id.count().reset_index()
print(clicks_by_source)

#pivot table for clicks by source
clicks_pivot = clicks_by_source.pivot(
  columns='is_click',
  index='utm_source',
  values='user_id'
).reset_index()

#new column in pivot table for % of users who clicked on ads
clicks_pivot['percent_clicked'] = clicks_pivot[True]/(clicks_pivot[True] + clicks_pivot[False])
print(clicks_pivot)

#analyzing an A/B Test
print(ad_clicks.groupby('experimental_group').user_id.count().reset_index())

#Check if greater % of users clicked on Ad A or Ad B and create pivot table from it
print(ad_clicks.groupby(['experimental_group', 'is_click']).user_id.count().reset_index().pivot(
  columns='is_click',
  index='experimental_group',
  values='user_id').reset_index())

#create dataframes for clicks per group
a_clicks = ad_clicks[ad_clicks.experimental_group == 'A']
b_clicks = ad_clicks[ad_clicks.experimental_group == 'B']

#pivot table for group A/clicks
a_clicks_pivot = a_clicks.groupby(['is_click', 'day']).user_id.count().reset_index().pivot(index='day',
  columns='is_click',
  values= 'user_id').reset_index()

#calculate % clicked for A and put into pivot table
a_clicks_pivot['percent_clicked'] = a_clicks_pivot[True]/(a_clicks_pivot[True]+a_clicks_pivot[False])
print(a_clicks_pivot)

#pivot table for group B/clicks
b_clicks_pivot = a_clicks.groupby(['is_click', 'day']).user_id.count().reset_index().pivot(index='day',
  columns='is_click',
  values= 'user_id').reset_index()

#calculate % clicked for B and put into pivot table
b_clicks_pivot['percent_clicked'] = b_clicks_pivot[True]/(b_clicks_pivot[True]+b_clicks_pivot[False])
print(b_clicks_pivot)
