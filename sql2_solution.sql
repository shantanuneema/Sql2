-- Solution to Problem 1 (without using window function, using correlated subquery)
SELECT s1.score, 
    (SELECT COUNT(DISTINCT s2.score)
     FROM Scores s2
     WHERE s2.score>=s1.score) AS 'rank'
FROM Scores s1
ORDER BY s1.score DESC

-- Solution to Problem 1 (with window function, I am confused why not specifying ORDER BY score at the end is not needed here)
SELECT score, DENSE_RANK() OVER (ORDER BY score DESC) as 'rank'
FROM Scores

-- Solution to Problem 1 (special case if NULL was present in the score)
SELECT 
    score, 
    CASE 
        WHEN score IS NULL THEN 1
        ELSE DENSE_RANK() OVER (ORDER BY score DESC) 
    END AS 'rank'
FROM Scores

-- Solution to Problem 1 (without using window function, using INNER JOIN or JOIN interchangiably)
-- Note: prefer JOIN over correlated subquery
SELECT S.score, COUNT(DISTINCT T.score) AS 'rank'
FROM Scores S
INNER JOIN Scores T
WHERE T.score >=  S.score
GROUP BY S.score, S.id
ORDER BY S.score DESC

-- Solution to Problem 2 (Using CASE Statement)
WITH CTE_maxID AS (SELECT MAX(id) AS max_id FROM Seat)
SELECT 
    CASE
        WHEN MOD(s.id, 2) = 0 THEN s.id - 1
        ELSE 
            CASE 
                WHEN MOD(s.id, 2) != 0 AND s.id != (SELECT max_id FROM CTE_maxID) THEN s.id + 1
            ELSE s.id
        END
    END AS 'id', s.student
FROM Seat s
ORDER BY id

-- Solution to Problem 2 (Using XOR bit Operator, no need to ORDER BY)
SELECT s1.id, IFNULL(s2.student, s1.student) as 'student'
FROM Seat s1 LEFT JOIN Seat s2 
ON (s1.id + 1) ^ 1 - 1 = s2.id

-- Solution to Problem 3 (Using simplified XOR using CASE)
WITH CTE_maxID AS (SELECT MAX(id) AS max_id FROM Seat)
SELECT 
    CASE
        WHEN id = (SELECT max_id FROM CTE_maxID) and MOD(id, 2) != 0 THEN id
        ELSE (id + 1)^1 - 1 END AS 'id', student
FROM Seat
ORDER BY id

-- Solution to Problem 3 (Using CASE statements, alternative is UNION using similar logic)
SELECT
    id,
    CASE 
        WHEN p_id IS NULL THEN 'Root'
        ELSE 
            CASE
            WHEN id IN (SELECT DISTINCT p_id FROM Tree WHERE p_id IS NOT NULL) THEN 'Inner' 
            ELSE 'Leaf'
        END
    END AS 'Type'
FROM Tree;

-- Solution to Problem 3 (Using IF statement)
SELECT
    id, IF(p_id IS NULL, 'Root', 
        IF(id IN (SELECT DISTINCT p_id FROM Tree WHERE p_id IS NOT NULL), 'Inner',
        'Leaf')) As 'Type'
FROM Tree;

-- Solution to Problem 4 
WITH CTE AS (
    SELECT e.*, DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS rnk
    FROM Employee e
)
SELECT 
    d.name AS Department, 
    c.name AS Employee, 
    c.salary AS Salary 
FROM CTE c JOIN Department d ON c.departmentId = d.id 
WHERE c.rnk <= 3;


