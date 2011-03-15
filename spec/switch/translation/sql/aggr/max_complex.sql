
WITH
-- binding due to aggregate
t0000 (iter3_nat, item4_int) AS
  (SELECT a0001.iter3_nat, MAX (a0001.item2_int) AS item4_int
     FROM (VALUES (1, 1),
                 (2, 1),
                 (3, 1)) AS a0001(item2_int,
          iter3_nat)
    GROUP BY a0001.iter3_nat),

-- binding due to set operation
t0001 (iter15_nat) AS
  ((SELECT a0000.iter12_nat AS iter15_nat
      FROM (VALUES (1)) AS a0000(iter12_nat))
   EXCEPT ALL
   (SELECT a0002.iter3_nat AS iter15_nat
      FROM t0000 AS a0002)),

-- binding due to set operation
t0002 (item5_int) AS
  ((SELECT a0007.item4_int AS item5_int
      FROM t0000 AS a0007)
   UNION ALL
   (SELECT a0008.item1_int AS item5_int
      FROM (VALUES (2)) AS a0008(item1_int))),

-- binding due to set operation
t0003 (item7_int) AS
  ((SELECT a0006.item6_int AS item7_int
      FROM (VALUES (1)) AS a0006(item6_int))
   UNION ALL
   (SELECT a0009.item5_int AS item7_int
      FROM t0002 AS a0009)),

-- bind as a column reference is needed in the following aggregate
t0004 (item7_int, iter8_nat) AS
  (SELECT a0010.item7_int, 1 AS iter8_nat
     FROM t0003 AS a0010),

-- binding due to aggregate
t0005 (iter8_nat, item9_int) AS
  (SELECT a0011.iter8_nat, MAX (a0011.item7_int) AS item9_int
     FROM t0004 AS a0011
    GROUP BY a0011.iter8_nat),

-- binding due to set operation
t0006 (iter13_nat) AS
  ((SELECT a0005.iter12_nat AS iter13_nat
      FROM (VALUES (1)) AS a0005(iter12_nat))
   EXCEPT ALL
   (SELECT a0012.iter8_nat AS iter13_nat
      FROM t0005 AS a0012))

SELECT 1 AS iter10_nat, a0015.item9_int
   FROM t0005 AS a0015;
