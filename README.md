# Indian-General-Election-2024-Analysis
**Problem Statement**
Does the outcome of India’s 18th Lok Sabha (2024) signal the revival of the Indian National Congress (INC)? Our client sought a deep, data-driven evaluation of this narrative using historical comparisons and political metrics.

**The Challenge**

One of the initial challenges was to define what “revival” of the Indian National Congress (INC) truly meant, not just in a measurable sense, but in its broader political context. Did it imply a return to the strength the party held during 2004? Or did it mean a rebound from its historic low in 2019, when it recorded one of its poorest performances in Indian electoral history?

After stakeholder consultations, we operationalized the term “revival” as -  to assess whether INC's 2024 performance indicates a meaningful improvement compared to its 2019 
baseline.

We distilled this into four core questions - 

How did INC perform in the 2024 election?

How does this compare to its performance in 2019?

Is there data-driven evidence of growth or resurgence?

What does this imply about INC’s future prospects  - both as a party and within alliances

👨‍💻 My Role & Contributions
I led the data cleaning, exploratory data analysis (EDA), and advanced SQL-based analytics and political metric modeling.

While the Election Commission of India (ECI) publishes comprehensive raw data, working with it involves several challenges:

Interpreting official definitions and electoral terms (e.g., total polled vote vs. total valid vote)

Resolving inconsistencies — e.g., Janasena Party is abbreviated as “JnP” in official documentation but listed as “JNP” in results data

Dealing with exclusions — e.g., Surat constituency (Gujarat) was excluded due to an uncontested BJP win with no votes cast

To ensure analysis integrity:

I used Pandas to preprocess and structure the data

Performed EDA and calculated metrics such as Index of Opposition Unity (IOU)

Exported the cleaned dataset as .csv for SQL-driven analysis

🔍 Key Metrics Comparison — INC Performance (2019 vs 2024)
Metric	2019	2024	Insight
Seats Won	52	99	🔼 Seat count nearly doubled, signaling a recovery
Overall Vote Share (%)	19.7	21.4	🔼 Slight improvement in vote base
Contested Vote Share (%)	25.1	30.2	🔼 +5.1 points — better targeting & alliance coordination
Seats Contested	421	328	🔽 Fewer contests, but more efficient
Seat Win % of Total Seats (%)	9.6	18.3	🔼 Shows overall electoral improvement
Seat Win % of Contested Seats (%)	12.4	34.9	🔼 High contest success rate in 2024
High IOU Seats (IOU > 0.9, vs BJP)	37	49	🔼 More tight contests, reflects better opposition consolidation


💼 Business Impact

**Helped the client quantify INC’s growth trajectory, grounded in solid metrics, not perception.**

**Insights were used to forecast future regional risks, validated by INC’s underperformance in follow-up Assembly elections.**

**Guided the client’s strategic communications around alliance effectiveness and regional dynamics.**

🧹 Data Cleaning Framework

Uploaded raw data files from the ECI official website (https://www.eci.gov.in/) some relevant files are in the ECI docs folder.

Identified key dimensions and measures in the dataset.

Classified columns as critical and non-critical for analysis.

Performed data formatting.

Conducted data consistency checks.

Checked and removed duplicate records.

Handled missing data using contextual imputation and exclusions.

Ensured correct data types for all dimensions and measures.

Created additional calculated columns.

📈 EDA Framework
Generated summary statistics for numerical and categorical fields.

Verified high-level metrics: total seats, vote polled, valid vote polled.

Reviewed unique values across dimensions.

Detected and documented anomalies and edge cases.

Developed derived metrics for in-depth analysis.
