# Case Study: Navigating Bike Share Patterns


## Introduction
This bike-share analysis case study aims to practice the skills I gained in the Google Data Analytics Professional Certificate and to showcase my eagerness and ability to work in this position.
## Scenario
I am a junior data analyst working at SunCycle, a bike-share company in San Francisco. The Director of Marketing believes that San Francisco has great potential for a large number of people to switch to bicycles and enjoy the true beauty of the city outdoors. Therefore, our analyst team aims to understand who currently favors bicycles and how we can reach a broader audience. Using these insights, our team will design a new marketing strategy to make the service more comfortable and user-friendly for both citizens and visitors, enabling more people to benefit from it.
## Ask
Objective: Design marketing strategies to reach a broader audience.
Guiding Questions for Analysis:
What is the most popular membership type?
How do annual/monthly members and casual riders utilize SunCycle bikes differently based on season, day of the week, and time of day?
Are bikes consistently available for daily use? Are there stations that may require additional docking points or new stations in proximity?

## Prepare 
The data used in this analysis originates from the San Francisco Ford GoBike Share datasets hosted on Google BigQuery. The dataset spans the years 2013 to 2018 and includes trip details such as trip id, start time, end time, trip duration, start station, end station, and latitude/longitude coordinates, capacity for each station. This comprehensive dataset, collected by SunCycle, provides insights into various aspects of cyclist behavior.
To facilitate analysis, the data was initially organized as separate files and saved in CSV format. In the BigQuery console, I queried two specific files, namely 'bikeshare_trips' and 'bikeshare_station_info.' These datasets were then joined, and the consolidated information was downloaded as a CSV file and stored locally on my PC.
## Process 
IIn the BigQuery console, the dataset turned out to be enormous, prompting the need for proper sorting and filtering to facilitate further analysis.
### Table: bikeshare_trips
I selected columns deemed useful for the analysis.
Changed the data type of the 'duration_sec' column, converting it to minutes and rounding numeric values to 2 decimals.
Joined two columns, 'subscriber_type' and 'c_subscription_type,' which were occasionally interchanging.
Since the table lacked data for the entire year, I focused on the accessible and informative period from July 2017 to April 2018.
During examination, I identified lines with NULL values in fields such as 'start_station_name,' 'end_station_name,' 'start_station_id,' and 'end_station_id.' I cleaned the table by eliminating rows where NULLs could pose potential issues.
Given that the table encompassed data from various regions, I applied filtering using the IN function and a subquery.

SELECT 
trip_id,
ROUND(CAST(duration_sec AS float64)/60,2) AS duration_min,
start_date,
start_station_name,
start_station_id,
end_date,
end_station_name,
end_station_id,
COALESCE(NULLIF(subscriber_type,'nan'),c_subscription_type) AS subscription_type,
start_station_latitude,
start_station_longitude,
end_station_latitude,
end_station_longitude
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
WHERE
FORMAT_TIMESTAMP('%Y'-%m-, start_date) >= '2017-07' AND
start_station_latitude IS NOT NULL AND
start_station_longitude IS NOT NULL AND
end_station_latitude IS NOT NULL AND
end_station_longitude IS NOT NULL AND
start_date < end_date AND
start_station_id IN (SELECT CAST(station_id AS INT64)
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`
WHERE region_id = 3)
Subsequently, I created a new dataset in my console profile and copied the refined table into it, containing a total of 695,867 rows. To ensure data integrity, I conducted a check to identify and address any duplicates or errors.


SELECT COUNT (DISTINCT trip_id)
FROM `bikeshare_project.bikeshare_trips`;


SELECT DISTINCT subscription_type
FROM `bikeshare_project.bikeshare_trips`
The number of rows was the same.
The data includes the following fields:
trip_id: Numeric ID of bike trip;
duration_min: Time of trip in minutes;
start_date: Start date of trip with date and time, in PST;
start_station_name:  Start date of trip with date and time, in PST;
start_station_id:  Numeric reference for start station;
end_date: End date of trip with date and time, in PST;
end_station_name: Station name for end station;
end_station_id: Numeric reference for end station;  
subscription_type: Subscriber = annual or 30-day member; Customer = 24-hour or 3-day member; 
start_station_latitude: The latitude of the start station; 
start_station_longitude: The longitude of the start station;  
end_station_latitude: The latitude of the start station;
end_station_longitude: The longitude of the end station.

### Table bakeshare_station_info
I selected relevant columns for analysis, removed duplicates using the DISTINCT function, and filtered the table to include only stations within the 3rd region (San Francisco).

SELECT 
DISTINCT station_id,
name,
lat,
lon,
capacity
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`
WHERE region_id = 3

I got 253 rows. 
The table contains the following fields:
station_id: Unique identifier of a station;
name: Public name of the station;
latitude: The latitude of station; 
longitude: The longitude of station;
capacity: Number of total docking points installed at this station, both available and unavailable.


Then I joined two tables that I got:
SELECT *
FROM `bikeshare_project.bikeshare_trips` AS trips
JOIN `bikeshare.bikeshare_station_info` AS stations
ON trips.start_station_id = stations.station_id

I confirmed that the number of rows remained consistent with the original table. Subsequently, I stored the refined table in my dataset and downloaded it to my PC.

## Analysis
What is the most popular type of membership?
The company offers two subscription types:
For Customers: 24-hour or 3-day membership,
For Subscribers: annual or 30-day membership.
Initially, I analyzed the proportion of total rides based on the subscription type:
The percentages on the pie chart represent the total rides for each type of membership. The vast majority of total rides belong to Subscribers, which is significant given their higher profitability, as indicated by the Director of Marketing.
How do annual/monthly members and casual riders utilize SunCycle bikes differently based on season, day of the week, and time of day?
Let’s check the patterns of behaviour during a week and average duration of rides for each group:

On the bar chart, we observe distinct riding patterns: Subscribers consistently use the service on workdays, with a significant drop on weekends, while Customers exhibit a preference for weekend rides, although the variation throughout weekdays is minimal.
Short-term subscription users tend to opt for longer rides, particularly in the range of 34 to 45 minutes, with the longest rides occurring on Saturdays and Sundays. In contrast, Subscribers have an average ride duration about one-third shorter, typically lasting 11 to 12 minutes.
Analyzing the rides per hour, we identify two peaks for Subscribers at 8 am and 5 pm, likely corresponding to commuting hours. For Customers, the chart displays a gradual increase in rides from 8 am to 5 pm without pronounced peaks.

Based on the observed patterns, it can be inferred that Subscribers utilize bikes more frequently on a daily basis, suggesting a primary use for commuting to work. Customers, on the other hand, engage in longer trips and actively use bikes throughout the entire week, with a slightly higher usage on weekends, likely indicating leisure activities.
This leads to the conclusion that Subscribers are predominantly residents or long-term visitors who rely on the service for daily commuting. In contrast, Customers are likely tourists who prefer to use the service during daylight hours, regardless of the day of the week.
While analyzing monthly rides, I was limited to 10 months (missing May and June), but we can still extract valuable insights from the following graph:

The popularity of bikes among Subscribers notably increases from August to October, followed by a decline until December. However, with each subsequent month, popularity rises progressively. Interestingly, bikes are used the least by Subscribers in August, potentially indicating a correlation with the vacation season during this period.
For Customers, bike popularity is evident from August to October and April. It can be inferred that these months, being some of the warmest in the year, attract higher tourism in the city.
Are bikes consistently available for daily use? Are there stations that may require additional docking points or new stations in proximity?
As the next step, I compared the distribution of bike stations based on the total rides (where each station serves as a starting point) and their respective capacities:

At first glance, both graphs correlate well. It's evident that a significant portion of the busiest stations has adequate capacity, although not all of them. Let's explore the practical implications:

It appears that there are several busiest stations where the capacity doesn't align with their popularity. This mismatch could lead to stations running out of bikes due to a shortage of docking points, ultimately impacting the comfort and convenience of the service.
Share
All charts and dashboards can be viewed interactively in Tableau.
## Act
While the Subscriber membership is more profitable, a successful marketing campaign could elevate the popularity of the Customer membership, particularly among tourists and visitors to the city. In summary, to reach a broader audience for each type of members, I made the following recommendations:
### Strategic Advertising:
Place advertisements in airports, train stations, buses to the city center, and popular tourist attractions.
Form partnerships with local businesses, such as hotels/hostels or events, for cross-promotion and discounts for bikeshare users.
### Digital Presence:
Advertise in map applications and other navigation tools.
Leverage social media platforms to create engaging content and share user stories.
Run social media campaigns or challenges to encourage user participation.
Seasonal and Location-Based Marketing:
Time the marketing campaign to coincide with warmer months and focus on the most used stations by Customers.
Identify popular stations among Customers using the provided dashboard.
### Incentive Programs:
Introduce a points-based plan where users accumulate points based on the distance traveled, offering discounts on the next subscription or other rewards.
Consider offering 30 minutes free for the first journey to attract new clients.
### Infrastructure Improvement:
Enhance service comfort by installing more docking points at highly used stations or constructing new stations in proximity.






















