
WITH
-- binding due to duplicate elimination
t0000 (item1_int) AS
  (SELECT DISTINCT a0000.item1_int
     FROM (VALUES (1),
                 (2),
                 (3),
                 (4),
                 (4),
                 (3),
                 (2),
                 (1)) AS a0000(item1_int))

SELECT 1 AS iter2_nat, a0001.item1_int
   FROM t0000 AS a0001;
