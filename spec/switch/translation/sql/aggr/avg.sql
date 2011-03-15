
WITH
-- binding due to aggregate
t0000 (iter2_nat, item3_dbl) AS
  (SELECT a0001.iter2_nat, AVG (a0001.item1_dbl) AS item3_dbl
     FROM (VALUES (1.5, 1),
                 (6, 1)) AS a0001(item1_dbl,
          iter2_nat)
    GROUP BY a0001.iter2_nat),

-- binding due to set operation
t0001 (iter7_nat) AS
  ((SELECT a0000.iter6_nat AS iter7_nat
      FROM (VALUES (1)) AS a0000(iter6_nat))
   EXCEPT ALL
   (SELECT a0002.iter2_nat AS iter7_nat
      FROM t0000 AS a0002))

SELECT 1 AS iter4_nat, a0005.item3_dbl
   FROM t0000 AS a0005;
