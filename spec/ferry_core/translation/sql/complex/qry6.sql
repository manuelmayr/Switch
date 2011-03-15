
WITH
-- binding due to rownum operator
t0000 (iter2_nat, item4_int, iter5_nat, item1_int, iter8_nat) AS
  (SELECT a0000.iter3_nat AS iter2_nat, a0000.item4_int, a0000.iter5_nat,
          a0001.item1_int,
          ROW_NUMBER () OVER (ORDER BY a0000.iter3_nat ASC, a0000.iter5_nat ASC)
          AS iter8_nat
     FROM (VALUES (1, 4, 1),
                 (2, 4, 1),
                 (3, 4, 1),
                 (1, 5, 2),
                 (2, 5, 2),
                 (3, 5, 2),
                 (1, 6, 3),
                 (2, 6, 3),
                 (3, 6, 3)) AS a0000(iter3_nat,
          item4_int,
          iter5_nat),
          (VALUES (1, 1),
                 (2, 2),
                 (3, 3)) AS a0001(item1_int,
          iter2_nat)
    WHERE a0000.iter3_nat = a0001.iter2_nat),

-- binding due to set operation
t0001 (iter11_nat, item12_int) AS
  ((SELECT a0003.iter8_nat AS iter11_nat, 8 AS item12_int
      FROM t0000 AS a0003)
   UNION ALL
   (SELECT a0004.iter8_nat AS iter11_nat, 9 AS item12_int
      FROM t0000 AS a0004)),

-- binding due to set operation
t0002 (iter14_nat, item15_int) AS
  ((SELECT a0002.iter8_nat AS iter14_nat, 7 AS item15_int
      FROM t0000 AS a0002)
   UNION ALL
   (SELECT a0005.iter11_nat AS iter14_nat, a0005.item12_int AS item15_int
      FROM t0001 AS a0005))

SELECT 1 AS iter26_nat, a0008.item1_int, a0007.item4_int, a0006.item15_int
   FROM t0002 AS a0006,
        t0000 AS a0007,
        t0000 AS a0008
  WHERE a0006.iter14_nat = a0007.iter8_nat
    AND a0006.iter14_nat = a0008.iter8_nat
    AND ((28 = ((a0008.item1_int * a0007.item4_int) * a0006.item15_int)) OR
        (((a0008.item1_int * a0007.item4_int) * a0006.item15_int) < 28));
