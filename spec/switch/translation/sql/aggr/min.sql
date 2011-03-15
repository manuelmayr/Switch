
WITH
-- binding due to aggregate
t0000 (iter2_nat, item3_int) AS
  (SELECT a0001.iter2_nat, MIN (a0001.item1_int) AS item3_int
     FROM (VALUES (1, 1),
                 (2, 1),
                 (3, 1),
                 (4, 1)) AS a0001(item1_int,
          iter2_nat)
    GROUP BY a0001.iter2_nat),

-- binding due to set operation
t0001 (iter7_nat) AS
  ((SELECT a0000.iter6_nat AS iter7_nat
      FROM (VALUES (1)) AS a0000(iter6_nat))
   EXCEPT ALL
   (SELECT a0002.iter2_nat AS iter7_nat
      FROM t0000 AS a0002))

SELECT 1 AS iter4_nat, a0005.item3_int
   FROM t0000 AS a0005;
