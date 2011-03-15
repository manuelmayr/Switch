
WITH
-- binding due to rank operator
t0000 (item15_str, iter16_nat, iter17_nat, pos18_nat) AS
  (SELECT a0000.item15_str, a0000.iter16_nat, a0000.iter17_nat,
          DENSE_RANK () OVER (ORDER BY a0000.iter16_nat ASC) AS pos18_nat
     FROM (VALUES ('foobar', 1, 2),
                 ('snafu', 2, 2)) AS a0000(item15_str,
          iter16_nat,
          iter17_nat)),

-- binding due to rank operator
t0001 (item6_dbl, iter7_nat, iter8_nat, pos9_nat) AS
  (SELECT a0002.item6_dbl, a0002.iter7_nat, a0002.iter8_nat,
          DENSE_RANK () OVER (ORDER BY a0002.iter7_nat ASC) AS pos9_nat
     FROM (VALUES (1.2, 1, 2),
                 (2.4, 2, 2)) AS a0002(item6_dbl,
          iter7_nat,
          iter8_nat)),

-- binding due to rank operator
t0002 (item1_int, item2_str, item3_dbl, iter4_nat, pos5_nat) AS
  (SELECT a0004.id AS item1_int, a0004.name AS item2_str,
          a0004.price AS item3_dbl, 1 AS iter4_nat,
          DENSE_RANK () OVER (ORDER BY a0004.name ASC) AS pos5_nat
     FROM article AS a0004),

-- binding due to set operation
t0003 (item10_str, item10_dbl, iter11_nat, pos12_nat) AS
  ((SELECT CAST(NULL AS VARCHAR(100)) AS item10_str,
           a0003.item6_dbl AS item10_dbl, a0003.iter8_nat AS iter11_nat,
           a0003.pos9_nat AS pos12_nat
      FROM t0001 AS a0003)
   UNION ALL
   (SELECT a0005.item2_str AS item10_str,
           CAST(NULL AS DECIMAL(20,10)) AS item10_dbl,
           a0005.iter4_nat AS iter11_nat, a0005.pos5_nat AS pos12_nat
      FROM t0002 AS a0005)),

-- binding due to rank operator
t0004 (item10_str, item10_dbl, iter11_nat, pos12_nat, iter13_nat,
  pos14_nat) AS
  (SELECT a0006.item10_str, a0006.item10_dbl, a0006.iter11_nat, a0006.pos12_nat,
          1 AS iter13_nat,
          DENSE_RANK () OVER
          (ORDER BY a0006.iter11_nat ASC, a0006.pos12_nat ASC) AS pos14_nat
     FROM t0003 AS a0006),

-- binding due to set operation
t0005 (item19_str, item19_dbl, iter20_nat, pos21_nat) AS
  ((SELECT a0001.item15_str AS item19_str,
           CAST(NULL AS DECIMAL(20,10)) AS item19_dbl,
           a0001.iter17_nat AS iter20_nat, a0001.pos18_nat AS pos21_nat
      FROM t0000 AS a0001)
   UNION ALL
   (SELECT a0007.item10_str AS item19_str, a0007.item10_dbl AS item19_dbl,
           a0007.iter13_nat AS iter20_nat, a0007.pos14_nat AS pos21_nat
      FROM t0004 AS a0007))

SELECT 1 AS iter22_nat, a0008.item19_dbl, a0008.item19_str
   FROM t0005 AS a0008
  ORDER BY a0008.iter20_nat ASC, a0008.pos21_nat ASC;
