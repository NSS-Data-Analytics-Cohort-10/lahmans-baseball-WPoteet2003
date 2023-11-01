-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT yearid, COUNT(yearid)
FROM batting
GROUP BY yearid
ORDER BY yearid;

--Answer: 1871 to 2016

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
   
SELECT namefirst, namelast, height, g_all, teamid
FROM people
FULL JOIN appearances
USING(playerid)
WHERE height IS NOT NULL
ORDER BY height ASC;

--Answer: Eddie Gaedel, 1 Game for St. Louis Browns

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
	
SELECT namefirst, namelast, schoolname, lgid, salary::numeric::money
FROM people
FULL JOIN salaries
USING(playerid)
FULL JOIN collegeplaying
USING(playerid)
FULL JOIN schools
USING(schoolid)
WHERE schoolname LIKE 'Vanderbilt%' AND salary IS NOT NULL
ORDER BY salary DESC
LIMIT(1);

--Answer: David Price, 30 Million

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
   
SELECT sum(po),
CASE 
WHEN pos IN ('OF') THEN 'Outfield'
WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
WHEN pos IN ('P', 'C') THEN 'Battery'
END area
FROM fielding
WHERE yearid = 2016
GROUP BY area;
   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   
SELECT ROUND((2*sum(so)::numeric/sum(g)::numeric),2) as strikeouts_per_game, 
CASE
WHEN yearid < 1880 THEN '1870s'
WHEN yearid < 1890 THEN '1880s'
WHEN yearid < 1900 THEN '1890s'
WHEN yearid < 1910 THEN '1900s'
WHEN yearid < 1920 THEN '1910s'
WHEN yearid < 1930 THEN '1920s'
WHEN yearid < 1940 THEN '1930s'
WHEN yearid < 1950 THEN '1940s'
WHEN yearid < 1960 THEN '1950s'
WHEN yearid < 1970 THEN '1960s'
WHEN yearid < 1980 THEN '1970s'
WHEN yearid < 1990 THEN '1980s'
WHEN yearid < 2000 THEN '1990s'
WHEN yearid < 2010 THEN '2000s'
ELSE '2010s'
END decade
FROM teams
GROUP BY decade
ORDER BY decade;

SELECT ROUND((2*sum(hr)::numeric/sum(g)::numeric),2) as homeruns_per_game, 
CASE
WHEN yearid < 1880 THEN '1870s'
WHEN yearid < 1890 THEN '1880s'
WHEN yearid < 1900 THEN '1890s'
WHEN yearid < 1910 THEN '1900s'
WHEN yearid < 1920 THEN '1910s'
WHEN yearid < 1930 THEN '1920s'
WHEN yearid < 1940 THEN '1930s'
WHEN yearid < 1950 THEN '1940s'
WHEN yearid < 1960 THEN '1950s'
WHEN yearid < 1970 THEN '1960s'
WHEN yearid < 1980 THEN '1970s'
WHEN yearid < 1990 THEN '1980s'
WHEN yearid < 2000 THEN '1990s'
WHEN yearid < 2010 THEN '2000s'
ELSE '2010s'
END decade
FROM teams
GROUP BY decade
ORDER BY decade;

--Answer: Strikeouts have gone up over time.  Homeruns have gone up as well.

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	
SELECT namefirst, namelast, ROUND(((sb::numeric)/(sb+cs)::numeric)*100,2) as steal_percentage
FROM people
FULL JOIN batting
USING(playerid)
WHERE (sb+cs) >= 20 AND yearid = 2016
ORDER BY steal_percentage DESC;

--Answer: Chris Owings with 91.30%

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT teamid, w, WSWin, yearid
FROM teams
WHERE WSWin = 'N' AND yearid >= 1970
ORDER BY w DESC;

SELECT teamid, w, WSWin, yearid
FROM teams
WHERE WSWin = 'Y' AND yearid >= 1970
ORDER BY w ASC;

--Skipping part 3 for rn

-- Answers: Seattle Mariners in 2001 with 116 games.  St. Loius Cardinals in 2006 with 83 games.

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT team, park, (attendance/games) as avg_attendance
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

SELECT team, park, (attendance/games) as avg_attendance
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY avg_attendance ASC
LIMIT 5;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT distinct(playerid), p.namefirst, p.namelast, teamid
FROM awardsmanagers a
LEFT JOIN awardsmanagers am
USING(playerid)
INNER JOIN managers m
USING(playerid)
INNER JOIN people p
USING(playerid)
WHERE (((a.awardid LIKE 'TSN%' AND a.lgid = 'NL') AND (am.awardid LIKE 'TSN%' AND am.lgid = 'AL')) 
OR ((a.awardid LIKE 'TSN%' AND a.lgid = 'AL') AND (am.awardid LIKE 'TSN%' AND am.lgid = 'NL'))) AND (m.yearid = a.yearid OR m.yearid = am.yearid);


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH max_hrs AS(
	SELECT playerid, MAX(hr), COUNT(yearid)
	FROM batting
	GROUP BY playerid
	HAVING MAX(hr) > 0 AND COUNT(yearid) >= 10
)
SELECT namefirst, namelast, hr, max
FROM batting
FULL JOIN max_hrs
USING(playerid)
LEFT JOIN people
USING(playerid)
WHERE yearid = 2016 AND hr = max;

-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT yearid, teamid, w, SUM(salary)
FROM salaries s
INNER JOIN teams t
USING(teamid, yearid)
GROUP BY yearid, teamid, w
HAVING yearid >= 2000
ORDER BY yearid, w DESC;

--Answer: A slight correlation, as higher salaried teams tend to be at the higher number of wins for the year.  The correlation is much weaker after a few years, though.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--       Does there appear to be any correlation between attendance at home games and number of wins?
--       Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

SELECT yearid, teamid, w, attendance
FROM teams t
WHERE yearid >= 2000
ORDER BY yearid, w DESC;

--Answer: A correlation could be present, but it seems very unlikely to have a large one, if one at all.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

SELECT throws, COUNT(throws)
FROM people
WHERE playerid IN (SELECT playerid FROM pitching)
GROUP BY throws
HAVING throws IS NOT NULL 
AND throws NOT LIKE 'S';

--About 27%, which is higher than the national average

SELECT throws, COUNT(throws), awardid
FROM awardsplayers
LEFT JOIN people
USING(playerid)
WHERE playerid IN (SELECT playerid FROM pitching)
GROUP BY throws, awardid
HAVING throws IS NOT NULL AND awardid LIKE 'Cy%';

--33%, which is even higher than the percentage in baseball.

SELECT throws, COUNT(throws), inducted
FROM halloffame
LEFT JOIN people
USING(playerid)
WHERE playerid IN (SELECT playerid FROM pitching)
GROUP BY throws, inducted, category
HAVING throws IS NOT NULL AND inducted LIKE 'Y' AND category = 'Player';

-- 23%, which is actually less than the baseball average.
