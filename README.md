# Indian-General-Election-2024-Analysis
**Problem Statement**

Does the outcome of India’s 18th Lok Sabha (2024) signal the revival of the Indian National Congress (INC)? Our client sought a deep, data-driven evaluation of this narrative using historical comparisons and political metrics.

**The Challenge**

One of the initial challenges was to define what “revival” of the Indian National Congress (INC) truly meant, not just in a measurable sense, but in its broader political context. Did it imply a return to the strength the party held during 2004? Or did it mean a rebound from its historic low in 2019, when it recorded one of its poorest performances in Indian electoral history?

After stakeholder consultations, we operationalized the term “revival” as -  to assess whether INC's 2024 performance indicates a meaningful improvement compared to its 2019 
baseline.

**We distilled this into four core questions-**

- How did INC perform in the 2024 election?

- How does this compare to its performance in 2019?

- Is there data-driven evidence of growth or resurgence?

- What does this imply about INC’s future prospects  - both as a party and within alliances

**My Role & Contributions**

I led the data cleaning, exploratory data analysis (EDA), and advanced SQL-based analytics and political metric modeling.

While the Election Commission of India (ECI) publishes comprehensive raw data, working with it involves several challenges:

- Interpreting official definitions and electoral terms (e.g., total polled vote vs. total valid vote)

- Resolving inconsistencies — e.g., Janasena Party is abbreviated as “JnP” in official documentation but listed as “JNP” in results data

- Dealing with exclusions — e.g., Surat constituency (Gujarat) was excluded due to an uncontested BJP win with no votes cast

To ensure analysis integrity:

- I used Pandas to preprocess and structure the data

- Performed EDA 

- Exported the cleaned dataset as .csv for SQL-driven analysis

**Key Insights (Due to the proprietary nature of the project, only a snapshot is provided.)**

- The INC nearly doubled its seat tally in 2024 compared to 2019, indicating a strong recovery from its historic low.

- Despite contesting fewer seats, INC's contested vote share increased by over 5 percentage points, showing better targeting and performance where it stood.

- Comparative IOU (Index of Opposition Unity) analysis revealed significantly higher opposition consolidation in many constituencies, reflecting a more strategic alliance approach.

- The INC’s gains were a result of both internal performance improvements and regional ally support, rather than organic growth alone.


**Business Impact**

- **Helped the client quantify INC’s growth trajectory, grounded in solid metrics, not perception.**

- **Insights were used to forecast future regional risks, validated by INC’s underperformance in follow-up Assembly elections.**

- **Guided the client’s strategic communications around alliance effectiveness and regional dynamics.**

**Data Cleaning Framework**

- Uploaded raw data files from the ECI official website (https://www.eci.gov.in/), some relevant files are in the ECI docs folder.

- Identified key dimensions and measures in the dataset.

- Classified columns as critical and non-critical for analysis.

- Performed data formatting.

- Conducted data consistency checks.

- Checked and removed duplicate records.

- Handled missing data using contextual imputation and exclusions.

- Ensured correct data types for all dimensions and measures.

- Created additional calculated columns.

**EDA Framework**

- Generated summary statistics for numerical and categorical fields.

- Verified high-level metrics: total seats, vote polled, valid vote polled.

- Reviewed unique values across dimensions.

- Detected and documented anomalies and edge cases.

- Developed derived metrics for in-depth analysis.
