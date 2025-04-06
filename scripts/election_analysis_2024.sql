use Election_India;

SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

SELECT
	*
FROM pc_24_for_sql;

-- Total Number of Seats

SELECT
	COUNT(pc_name) AS total_seats
FROM pc_24_for_sql
WHERE rank = 1;

-- State wise number of Seats
SELECT 
	state_name,
	COUNT(DISTINCT pc_name) TotalSeats
FROM pc_24_for_sql
GROUP BY state_name
ORDER BY TotalSeats DESC;


-- Number of seats won by alliance
SELECT
	alliance,
	COUNT(rank) as seats_won,
	SUM(COUNT(rank)) OVER() AS total_seats
FROM pc_24_for_sql
WHERE rank = 1
GROUP BY alliance
ORDER BY seats_won DESC;

-- Seats Won by Each Party 

SELECT
	main_party,
	COUNT(pc_name) AS seats_won
FROM pc_24_for_sql
WHERE rank = 1
GROUP BY main_party
ORDER BY seats_won DESC;

-- contested seats by each party
SELECT 
	main_party,
	COUNT(DISTINCT CONCAT(state_name,' ',pc_name)) AS contested_seats
FROM pc_24_for_sql
GROUP BY main_party
ORDER BY contested_seats DESC;

-- Winning percentage by contested seats and overall seats
WITH cte_seats AS 
(
	SELECT DISTINCT
		main_party,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY main_party) AS seats_won,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER() AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY main_party) as contested_seats
	FROM pc_24_for_sql
) 
SELECT
	main_party,
	seats_won,
	contested_seats,
	total_seats,
	ROUND((seats_won/CAST(contested_seats AS FLOAT))*100,1) AS contested_winning_percentage,
	ROUND((seats_won/CAST(total_seats AS FLOAT))*100,1)  AS winning_percentage
FROM cte_seats
ORDER BY seats_won DESC;

-- Total Votes Secured by Each Main Party with percentage

WITH cte_constituency_valid_votes AS -- total valid votes per pc
(	SELECT
		state_name,
		pc_name,
		SUM(CAST(total_vote_secured AS BIGINT)) AS total_valid_votes
FROM pc_24_for_sql
GROUP BY state_name,pc_name
),
cte_party_valid_votes AS -- total valid votes for each party
(
SELECT
	p.main_party,
	SUM(cv.total_valid_votes) AS total_valid_votes_party
FROM pc_24_for_sql p
JOIN cte_constituency_valid_votes cv
ON p.state_name = cv.state_name AND p.pc_name = cv.pc_name
GROUP BY p.main_party
)

SELECT DISTINCT
	p.main_party,
	pv.total_valid_votes_party,
	SUM(p.total_vote_secured) OVER(PARTITION BY p.main_party) AS total_vote_secured,
	SUM(p.total_vote_secured) OVER() AS total_valid_votes,
	ROUND((SUM(p.total_vote_secured) OVER(PARTITION BY p.main_party)/CAST(SUM(p.total_vote_secured) OVER() AS FLOAT))*100,1) AS vote_share,
	ROUND(SUM(p.total_vote_secured) OVER(PARTITION BY p.main_party)/CAST(pv.total_valid_votes_party AS FLOAT)*100,1) AS contested_vote_share
FROM pc_24_for_sql p
JOIN cte_party_valid_votes pv
ON p.main_party = pv.main_party
ORDER BY total_vote_secured DESC;

-- Performace Evaluation of INC

-- creating required view for analysis

--1 pc level valid votes (view)

 CREATE VIEW pc_level_valid_votes_24 AS
SELECT
    state_name,
    pc_name,
    SUM(CAST(total_vote_secured AS BIGINT)) AS total_valid_votes
FROM pc_24_for_sql
GROUP BY state_name, pc_name;

-- 2. party level valid votes (view)

CREATE VIEW party_level_valid_votes_24 AS
SELECT
	p.main_party,
	SUM(pcv.total_valid_votes) AS total_valid_votes_party
FROM pc_24_for_sql p
JOIN pc_level_valid_votes_24 pcv
ON p.state_name = pcv.state_name AND p.pc_name = pcv.pc_name
GROUP BY p.main_party;

-- 3. Seat analysis (view)

CREATE VIEW seat_analysis AS
SELECT DISTINCT
		main_party,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY main_party) AS seats_won,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER() AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY main_party) as contested_seats
FROM pc_24_for_sql

--# Checking the views
SELECT DISTINCT
	s.main_party,
	s.seats_won,
	s.total_seats,
	s.contested_seats,
	ROUND((seats_won/CAST(total_seats AS FLOAT))*100,1) AS winning_percentage,
	ROUND((seats_won/CAST(contested_seats AS FLOAT))*100,1) AS contested_winning_percentage,
	SUM(p.total_vote_secured) OVER(PARTITION BY s.main_party) AS total_vote_secured,
	SUM(p.total_vote_secured) OVER() AS total_valid_votes,
	pv.total_valid_votes_party,
	ROUND((SUM(p.total_vote_secured) OVER(PARTITION BY s.main_party)/CAST(SUM(p.total_vote_secured) OVER() AS FLOAT))*100,1) AS vote_share,
	ROUND((SUM(p.total_vote_secured) OVER(PARTITION BY s.main_party)/CAST(pv.total_valid_votes_party AS FLOAT))*100,1) AS contested_vote_share
FROM seat_analysis s
JOIN pc_24_for_sql p
ON s.main_party = p.main_party
JOIN party_level_valid_votes_24 pv
ON s.main_party = pv.main_party
ORDER BY s.seats_won DESC;

-- Performance evaluation of INC (1)
	-- Total seats won
	-- contested seats 
	-- winning percentage
	-- vote share
	-- contested vote share

WITH cte_main_party_performance AS
(
SELECT DISTINCT
	s.main_party,
	s.seats_won,
	s.total_seats,
	s.contested_seats,
	ROUND((seats_won/CAST(total_seats AS FLOAT))*100,1) AS winning_percentage,
	ROUND((seats_won/CAST(contested_seats AS FLOAT))*100,1) AS contested_winning_percentage,
	SUM(p.total_vote_secured) OVER(PARTITION BY s.main_party) AS total_vote_secured,
	SUM(p.total_vote_secured) OVER() AS total_valid_votes,
	pv.total_valid_votes_party,
	ROUND((SUM(p.total_vote_secured) OVER(PARTITION BY s.main_party)/CAST(SUM(p.total_vote_secured) OVER() AS FLOAT))*100,1) AS vote_share,
	ROUND((SUM(p.total_vote_secured) OVER(PARTITION BY s.main_party)/CAST(pv.total_valid_votes_party AS FLOAT))*100,1) AS contested_vote_share
FROM seat_analysis s
JOIN pc_24_for_sql p
ON s.main_party = p.main_party
JOIN party_level_valid_votes_24 pv
ON s.main_party = pv.main_party
)
SELECT 
	*
FROM cte_main_party_performance
WHERE main_party = 'INC';

-- BY PC CATEGORY Vote Share and Seats

WITH cte_pc_category AS 
(
	SELECT
		pc_category,
		SUM(total_vote_secured) total_vote_by_pc_category 
	FROM pc_24_for_sql
	GROUP BY pc_category
)
SELECT
	p.pc_category,
	p.main_party,
	SUM(p.total_vote_secured) AS total_vote_secured,
	cc.total_vote_by_pc_category,
	ROUND((SUM(p.total_vote_secured)/CAST(cc.total_vote_by_pc_category AS FLOAT))*100,1) AS vote_share
FROM pc_24_for_sql p
JOIN cte_pc_category cc
ON p.pc_category = cc.pc_category
WHERE main_party = 'INC'
GROUP BY p.pc_category,main_party,cc.total_vote_by_pc_category;

-- by pc category seats
SELECT
	*,
	ROUND((total_seats_won/CAST(total_seats_by_category AS FLOAT))*100,1) AS winning_percentage
FROM
(
SELECT DISTINCT
	main_party,
	pc_category,
	SUM(CASE WHEN rank = 1 THEN 1 END) OVER() AS total_seats,
	SUM(CASE WHEN rank = 1 THEN 1 END) OVER(PARTITION BY pc_category) AS total_seats_by_category,
	SUM(CASE WHEN rank = 1 THEN 1 END) OVER(PARTITION BY pc_category,main_party) AS total_seats_won
FROM pc_24_for_sql) t 
WHERE main_party = 'INC'






-- State wise performance of INC
	-- state wise contested seat
	-- state wise seats won
	-- state wise vote share

SELECT DISTINCT -- State wise performance for all main party
		state_name,
		main_party,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name, main_party) AS seats_won,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name) AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY state_name, main_party) as contested_seats
FROM pc_24_for_sql
ORDER BY seats_won DESC, state_name DESC;

-- this is for calculation
SELECT DISTINCT
		state_name,
		main_party,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name) AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY state_name, main_party) as contested_seats,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name, main_party) AS seats_won,
		SUM(total_vote_secured) OVER(PARTITION BY state_name,main_party) AS state_wise_total_vote,
		SUM(total_vote_secured) OVER() AS total_valid_votes
FROM pc_24_for_sql

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
		main_party,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name) AS total_seats,
		COUNT(pc_name) OVER(PARTITION BY state_name, main_party) as contested_seats,
		COUNT(CASE WHEN rank = 1 THEN 1 END)  OVER(PARTITION BY state_name, main_party) AS seats_won,
		SUM(total_vote_secured) OVER(PARTITION BY state_name,main_party) AS state_wise_total_vote_secured,
		SUM(total_vote_secured) OVER(PARTITION BY state_name) AS state_wise_total_valid_votes
FROM pc_24_for_sql
) t
WHERE main_party = 'INC'
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
FROM pc_24_for_sql
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

SELECT
	state_name,
	pc_name,
	party_name,
	total_vote_secured,
	rank,
	margin_difference
FROM pc_24_for_sql
WHERE party_name = 'INC' AND rank = 1;


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
FROM pc_24_for_sql
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
FROM pc_24_for_sql
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
		main_party AS winner_bjp,
		total_vote_secured AS winning_vote_bjp
	FROM pc_24_for_sql
	WHERE rank = 1 AND main_party = 'BJP'
),
cte_runnerup AS
	(
	SELECT
		state_name,
		pc_name,
		main_party AS runner_up_party,
		total_vote_secured AS runner_vote
	FROM pc_24_for_sql
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

-- Vote to Seat Convertion

WITH inc_votes AS (
    SELECT
        SUM(total_vote_secured) AS inc_total_votes
    FROM pc_24_for_sql
    WHERE main_party = 'INC'
),
total_votes AS (
    SELECT
        SUM(total_vote_secured) AS all_votes
    FROM pc_24_for_sql
),
inc_seats AS (
    SELECT
        COUNT(*) AS inc_won_seats
    FROM pc_24_for_sql
    WHERE rank = 1 AND main_party = 'INC'
),
total_seats AS (
    SELECT
		COUNT(pc_name) AS total_seats
	FROM pc_24_for_sql
	WHERE rank = 1
)
SELECT
    CAST(inc_won_seats AS FLOAT)/total_seats AS inc_seat_share,
    CAST(inc_total_votes AS FLOAT)/all_votes AS inc_vote_share,
    ROUND(CAST(inc_won_seats AS FLOAT)/total_seats / NULLIF(CAST(inc_total_votes AS FLOAT)/all_votes, 0), 2) AS vote_to_seat_ratio
FROM inc_votes, total_votes, inc_seats, total_seats;






-- IOU Calulations > .9
WITH cte_winners_bjp AS
	(
	SELECT
		state_name,
		pc_name,
		main_party AS winner_bjp,
		total_vote_secured AS winning_vote_bjp
	FROM pc_24_for_sql
	WHERE rank = 1 AND main_party = 'BJP'
),
cte_runnerup_inc AS
	(
	SELECT
		state_name,
		pc_name,
		main_party AS runner_inc,
		total_vote_secured AS runner_vote_inc
	FROM pc_24_for_sql
	WHERE rank = 2 AND main_party = 'INC'
),
cte_third_position AS 
(
	SELECT
		state_name,
		pc_name,
		party_name AS third_position_party,
		total_vote_secured AS third_position_party_vote
	FROM pc_24_for_sql
	WHERE rank = 3
)
SELECT
	cw.state_name,
	cw.pc_name,
	cw.winner_bjp,
	cw.winning_vote_bjp,
	cr.runner_inc,
	cr.runner_vote_inc,
	cp.third_position_party,
	cp.third_position_party_vote,
	ROUND(cr.runner_vote_inc/CAST(cw.winning_vote_bjp AS FLOAT),1) AS IOU,
	(cw.winning_vote_bjp - cr.runner_vote_inc) AS vote_margin
FROM cte_winners_bjp cw
JOIN cte_runnerup_inc cr
ON cw.state_name = cr.state_name AND cw.pc_name = cr.pc_name
LEFT JOIN cte_third_position cp
ON cw.state_name = cp.state_name AND cw.pc_name = cp.pc_name
--WHERE (cr.runner_vote_inc/CAST(cw.winning_vote_bjp AS FLOAT) >= 0.9) AND (cp.third_position_party IS NOT NULL)
ORDER BY IOU DESC;


-- IOU Calulations < .5
WITH cte_winners_bjp AS
	(
	SELECT
		state_name,
		pc_name,
		main_party AS winner_bjp,
		total_vote_secured AS winning_vote_bjp
	FROM pc_24_for_sql
	WHERE rank = 1 AND main_party = 'BJP'
),
cte_runnerup_inc AS
	(
	SELECT
		state_name,
		pc_name,
		main_party AS runner_inc,
		total_vote_secured AS runner_vote_inc
	FROM pc_24_for_sql
	WHERE rank = 2 AND main_party = 'INC'
),
cte_third_position AS 
(
	SELECT
		state_name,
		pc_name,
		party_name AS third_position_party,
		total_vote_secured AS third_position_party_vote
	FROM pc_24_for_sql
	WHERE rank = 3
)
SELECT
	cw.state_name,
	cw.pc_name,
	cw.winner_bjp,
	cw.winning_vote_bjp,
	cr.runner_inc,
	cr.runner_vote_inc,
	cp.third_position_party,
	cp.third_position_party_vote,
	ROUND(cr.runner_vote_inc/CAST(cw.winning_vote_bjp AS FLOAT),1) AS IOU,
	(cw.winning_vote_bjp - cr.runner_vote_inc) AS vote_margin
FROM cte_winners_bjp cw
JOIN cte_runnerup_inc cr
ON cw.state_name = cr.state_name AND cw.pc_name = cr.pc_name
LEFT JOIN cte_third_position cp
ON cw.state_name = cp.state_name AND cw.pc_name = cp.pc_name
WHERE (cr.runner_vote_inc/CAST(cw.winning_vote_bjp AS FLOAT) < 0.5) AND (cp.third_position_party IS NOT NULL)
ORDER BY IOU DESC




























	





