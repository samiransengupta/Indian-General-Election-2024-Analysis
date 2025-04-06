USE Election_India

-- 2019 data
SELECT
	*
FROM pc_19_for_sql;

-- Total Number of Seats

SELECT
	COUNT(pc_name) AS total_seats
FROM pc_19_for_sql
WHERE rank = 1;

-- State wise number of seats

SELECT
	state_name,
	COUNT(DISTINCT pc_name) total_seats
FROM pc_19_for_sql
GROUP BY state_name
ORDER BY total_seats DESC

-- Seats won by each party
SELECT
	party_name,
	COUNT(pc_name) as seats_won
FROM pc_19_for_sql
WHERE rank = 1
GROUP BY party_name
ORDER BY seats_won DESC;

-- contested seats by each party
SELECT 
	party_name,
	COUNT(DISTINCT CONCAT(state_name,' ',pc_name)) AS contested_seats
FROM pc_19_for_sql
GROUP BY party_name
ORDER BY contested_seats DESC;

-- Winning percentage by contested seats and overall seats
WITH cte_seats AS 
(
	SELECT DISTINCT
		party_name,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY party_name) AS seats_won,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER() AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY party_name) as contested_seats
	FROM pc_19_for_sql
) 
SELECT
	party_name,
	seats_won,
	contested_seats,
	total_seats,
	ROUND((seats_won/CAST(contested_seats AS FLOAT))*100,1) AS contested_winning_percentage,
	ROUND((seats_won/CAST(total_seats AS FLOAT))*100,1)  AS winning_percentage
FROM cte_seats
ORDER BY seats_won DESC;

-- Total Votes Secured by Each Party with percentage

WITH cte_constituency_valid_votes AS -- total valid votes per pc
(	SELECT
		state_name,
		pc_name,
		SUM(CAST(total_vote_secured AS BIGINT)) AS total_valid_votes
FROM pc_19_for_sql
GROUP BY state_name,pc_name
),
cte_party_valid_votes AS -- total valid votes for each party
(
SELECT
	p.party_name,
	SUM(cv.total_valid_votes) AS total_valid_votes_party
FROM pc_19_for_sql p
JOIN cte_constituency_valid_votes cv
ON p.state_name = cv.state_name AND p.pc_name = cv.pc_name
GROUP BY p.party_name
)

SELECT DISTINCT
	p.party_name,
	pv.total_valid_votes_party,
	SUM(p.total_vote_secured) OVER(PARTITION BY p.party_name) AS total_vote_secured,
	SUM(p.total_vote_secured) OVER() AS total_valid_votes,
	ROUND((SUM(p.total_vote_secured) OVER(PARTITION BY p.party_name)/CAST(SUM(p.total_vote_secured) OVER() AS FLOAT))*100,1) AS vote_share,
	ROUND(SUM(p.total_vote_secured) OVER(PARTITION BY p.party_name)/CAST(pv.total_valid_votes_party AS FLOAT)*100,1) AS contested_vote_share
FROM pc_19_for_sql p
JOIN cte_party_valid_votes pv
ON p.party_name = pv.party_name
ORDER BY total_vote_secured DESC;



-- Seat and Vote Share by pc category

-- Vote Share
WITH cte_pc_category AS 
(
	SELECT
		pc_category,
		SUM(total_vote_secured) total_vote_by_pc_category 
	FROM pc_19_for_sql
	GROUP BY pc_category
)
SELECT
	p.pc_category,
	p.party_name,
	SUM(p.total_vote_secured) AS total_vote_secured,
	cc.total_vote_by_pc_category,
	ROUND((SUM(p.total_vote_secured)/CAST(cc.total_vote_by_pc_category AS FLOAT))*100,1) AS vote_share
FROM pc_19_for_sql p
JOIN cte_pc_category cc
ON p.pc_category = cc.pc_category
WHERE party_name = 'INC'
GROUP BY p.pc_category,p.party_name,cc.total_vote_by_pc_category;

-- Seat Share

SELECT
	*,
	ROUND((total_seats_won/CAST(total_seats_by_category AS FLOAT))*100,1) AS winning_percentage
FROM
(
SELECT DISTINCT
	party_name,
	pc_category,
	SUM(CASE WHEN rank = 1 THEN 1 END) OVER() AS total_seats,
	SUM(CASE WHEN rank = 1 THEN 1 END) OVER(PARTITION BY pc_category) AS total_seats_by_category,
	SUM(CASE WHEN rank = 1 THEN 1 END) OVER(PARTITION BY pc_category,party_name) AS total_seats_won
FROM pc_19_for_sql) t 
WHERE party_name = 'INC';

-- State wise performance of INC
SELECT
	state_name,
	total_seats,
	contested_seats,
	seats_won,
	SUM(seats_won) OVER () AS total_seats_won,
	state_wise_total_vote_secured,
	state_wise_total_valid_votes,
	SUM(state_wise_total_vote_secured) OVER() AS total_vote_secured_inc,
	ROUND((state_wise_total_vote_secured/CAST(state_wise_total_valid_votes AS FLOAT))*100,1) AS state_wise_vote_share
FROM
(SELECT DISTINCT
		state_name,
		party_name,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name) AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY state_name, party_name) as contested_seats,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name, party_name) AS seats_won,
		SUM(total_vote_secured) OVER(PARTITION BY state_name,party_name) AS state_wise_total_vote_secured,
		SUM(total_vote_secured) OVER(PARTITION BY state_name) AS state_wise_total_valid_votes
FROM pc_19_for_sql
) t
WHERE party_name = 'INC'
ORDER BY seats_won DESC;


-- Margin of Victory and Loss analysis INC
WITH cte_inc_margin AS -- Victry
(
SELECT
	state_name,
	pc_name,
	party_name,
	total_vote_secured,
	rank,
	COALESCE(LEAD(total_vote_secured) OVER(PARTITION BY state_name, pc_name ORDER BY rank), 0) AS runner_up_votes,
    COALESCE(LAG(total_vote_secured) OVER(PARTITION BY state_name, pc_name ORDER BY rank), 0) AS winner_votes
FROM pc_19_for_sql
) 
SELECT
	state_name,
	pc_name,
	total_vote_secured AS inc_total_vote_secured,
	total_vote_secured - runner_up_votes AS victry_margin,
	ROUND(((total_vote_secured - runner_up_votes)/CAST(total_vote_secured AS FLOAT))*100,1) AS victory_margin_percentage
FROM cte_inc_margin
WHERE party_name = 'INC' AND rank = 1
ORDER BY victory_margin_percentage DESC;

WITH cte_inc_margin AS -- Loss
(
SELECT
	state_name,
	pc_name,
	party_name,
	total_vote_secured,
	rank,
	COALESCE(LEAD(total_vote_secured) OVER(PARTITION BY state_name, pc_name ORDER BY rank), 0) AS runner_up_votes,
    COALESCE(LAG(total_vote_secured) OVER(PARTITION BY state_name, pc_name ORDER BY rank), 0) AS winner_votes
FROM pc_19_for_sql
) 
SELECT
	state_name,
	pc_name,
	total_vote_secured AS inc_total_vote_secured,
	winner_votes - total_vote_secured AS loss_margin,
	ROUND(((winner_votes - total_vote_secured)/CAST(winner_votes AS FLOAT))*100,1) AS loss_margin_percentage
FROM cte_inc_margin
WHERE party_name = 'INC' AND rank > 1
ORDER BY loss_margin_percentage;

-- IOU Calculation
WITH cte_winners_bjp AS
	(
	SELECT
		state_name,
		pc_name,
		party_name AS winner_bjp,
		total_vote_secured AS winning_vote_bjp
	FROM pc_19_for_sql
	WHERE rank = 1 AND party_name = 'BJP'
),
cte_runnerup AS
	(
	SELECT
		state_name,
		pc_name,
		party_name AS runner_up_party,
		total_vote_secured AS runner_vote
	FROM pc_19_for_sql
	WHERE rank = 2 
)
SELECT
	cw.state_name,
	cw.pc_name,
	cw.winner_bjp,
	cw.winning_vote_bjp,
	cr.runner_up_party,
	cr.runner_vote,
	
	ROUND(cr.runner_vote/CAST(cw.winning_vote_bjp AS FLOAT),1) AS IOU,
	(cw.winning_vote_bjp - cr.runner_vote) AS vote_margin
FROM cte_winners_bjp cw
JOIN cte_runnerup cr
ON cw.state_name = cr.state_name AND cw.pc_name = cr.pc_name
WHERE (cr.runner_vote/CAST(cw.winning_vote_bjp AS FLOAT) >= 0.9) 
ORDER BY IOU DESC;

-- Vote to Seat
WITH inc_votes AS (
    SELECT
        SUM(total_vote_secured) AS inc_total_votes
    FROM pc_19_for_sql
    WHERE party_name = 'INC'
),
total_votes AS (
    SELECT
        SUM(total_vote_secured) AS all_votes
    FROM pc_19_for_sql
),
inc_seats AS (
    SELECT
        COUNT(*) AS inc_won_seats
    FROM pc_19_for_sql
    WHERE rank = 1 AND party_name = 'INC'
),
total_seats AS (
    SELECT
		COUNT(pc_name) AS total_seats
	FROM pc_19_for_sql
	WHERE rank = 1
)
SELECT
    CAST(inc_won_seats AS FLOAT)/total_seats AS inc_seat_share,
    CAST(inc_total_votes AS FLOAT)/all_votes AS inc_vote_share,
    ROUND(CAST(inc_won_seats AS FLOAT)/total_seats / NULLIF(CAST(inc_total_votes AS FLOAT)/all_votes, 0), 2) AS vote_to_seat_ratio
FROM inc_votes, total_votes, inc_seats, total_seats;











