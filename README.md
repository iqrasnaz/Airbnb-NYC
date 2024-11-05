# New York City Airbnb Analysis

![folium_map](https://github.com/user-attachments/assets/c1695b3a-c088-4b8b-92bd-7f8855919093)

## **Project Overview:** 

This analysis addresses key factors influencing Airbnb bookings in NYC. Inspired by personal travel challenges, this project explores host performance, pricing, guest preferences, and property availability to support better booking decisions.

## **Objectives:**

* Identify host traits that drive booking success
* Analyze location and amenities' impact on pricing and demand
* Study seasonal and listing availability trends

## **Data Summary:**

* Source: [Inside Airbnb](https://insideairbnb.com/get-the-data/) (2024)
* Data cleaning performed in Excel (removing unnecessary data) and Python (imputing missing values)
* Size: 37,000+ rows and 49 features after cleaning

## **Key Findings:**

* Host Performance: Hosts with high response rates see 49% more bookings. Superhosts receive slightly higher ratings but are not necessarily more frequently booked.
* Location & Pricing: Manhattan listings have higher demand and pricing. Listings that offer more amenities generally receive higher ratings. Entire homes/apartments in prime locations see up to 17% more bookings than shared spaces.
* Review Impact: High review scores boost bookings, particularly cleanliness and accuracy. Lower scores indicate areas for host improvement; 52% of hosts have low ratings. 
* Availability Trends: On average, guests book their stay for 29 nights. Manhattan has the highest availability all year round.

## **Predictive Modeling:**

* Predictive Models: Random Forests predict price and booking success based on features such as host status, location, and guest review scores, etc.

## **EDA & Visualizations**

<div style="display: flex; flex-wrap: wrap; gap: 5px; justify-content: center;">

  <!-- First Row -->
  <div style="display: flex; width: 100%; justify-content: center;">
    <img src="https://github.com/user-attachments/assets/4f08155a-ecd5-4cd5-93e3-947c8a69a0b3" alt="bar_top_host_ids" style="width: 49%; height: auto;">
    <img src="https://github.com/user-attachments/assets/0ccf39ee-b05a-4a22-94ec-44c11f9b79fc" alt="kde_plots_borough_availability" style="width: 49%; height: auto;">
  </div>

  <!-- Second Row (Single Image) -->
  <div style="display: flex; width: 100%; justify-content: center;">
    <img src="https://github.com/user-attachments/assets/dd5c478f-3231-4cfc-853e-ed320f38ff94" alt="violin_prices_by_room_borough" style="width: 98%; height: auto;">
  </div>

  <!-- Third Row -->
  <div style="display: flex; width: 100%; justify-content: center;">
    <img src="https://github.com/user-attachments/assets/009eb44a-0018-414a-a40e-05c04be5ecba" alt="lineplot_seasonality_month" style="width: 49%; height: auto;">
    <img src="https://github.com/user-attachments/assets/95d9eb60-4dcd-4a29-887e-14c0a0e62fe0" alt="barplot_seasonality_year" style="width: 49%; height: auto;">
  </div>

</div>



* [Interactive Tableau Dashboard](https://public.tableau.com/app/profile/iqra.naz/viz/AirbnbAnalysis_17292270230920/Overview)

 <div style="display: flex; flex-wrap: wrap; gap: 5px; justify-content: center;">
  <div style="display: flex; width: 100%; justify-content: center;">
    <img src="https://github.com/user-attachments/assets/e761e8b6-fc31-4cf0-867c-02a4deccd400" alt="tab_dash" style="width: 100%; height: auto;">
  </div>
  </div>

## ** Business Recommendations:**

* Host Behavior: Automate responses to improve response rates; workshops for guest service.
* Neighborhood Marketing: Target popular areas like Bedford-Stuyvesant and Williamsburg, while promoting unique listings in quieter locations.
* Seasonal Pricing Adjustments: Align prices with demand, particularly in highly rated boroughs (e.g., Manhattan or Brooklyn) and in peak months (August-October).

## **Tools & Skills:**

* Excel, Python, MySQL, Tableau
* Data cleaning, Pandas, Matplotlib, Data Manipulation, Exploratory Data Analysis, Window Functions, CTEs, Data Visualization
* Acknowledgment: Thank you to Inside Airbnb for providing this public data.
