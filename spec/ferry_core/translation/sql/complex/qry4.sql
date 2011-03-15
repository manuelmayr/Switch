
WITH
-- binding due to set operation
t0000 (iter13_nat, item14_int, iter15_nat) AS
  ((SELECT a0001.iter9_nat AS iter13_nat,
           (a0001.item8_int + a0001.item10_int) AS item14_int, 2 AS iter15_nat
      FROM (VALUES (1, 1, 2),
                  (2, 2, 2),
                  (3, 3, 2)) AS a0001(item8_int,
           iter9_nat,
           item10_int))
   UNION ALL
   (SELECT a0002.iter4_nat AS iter13_nat,
           (a0002.item3_int + a0002.item5_int) AS item14_int, 3 AS iter15_nat
      FROM (VALUES (1, 1, 3),
                  (2, 2, 3),
                  (3, 3, 3)) AS a0002(item3_int,
           iter4_nat,
           item5_int))),

-- binding due to set operation
t0001 (iter21_nat, item22_int, iter23_nat) AS
  ((SELECT a0000.iter17_nat AS iter21_nat,
           (a0000.item16_int + a0000.item18_int) AS item22_int, 1 AS iter23_nat
      FROM (VALUES (1, 1, 1),
                  (2, 2, 1),
                  (3, 3, 1)) AS a0000(item16_int,
           iter17_nat,
           item18_int))
   UNION ALL
   (SELECT a0003.iter13_nat AS iter21_nat, a0003.item14_int AS item22_int,
           a0003.iter15_nat AS iter23_nat
      FROM t0000 AS a0003)),

-- binding due to rownum operator
t0002 (iter2_nat, item22_int, iter23_nat, iter1_nat, pos26_nat) AS
  (SELECT a0004.iter21_nat AS iter2_nat, a0004.item22_int, a0004.iter23_nat,
          a0005.iter1_nat,
          ROW_NUMBER () OVER
          (PARTITION BY a0005.iter1_nat ORDER BY a0004.iter23_nat ASC) AS
          pos26_nat
     FROM t0001 AS a0004,
          (VALUES (1, 1),
                 (2, 2),
                 (3, 3)) AS a0005(iter1_nat,
          iter2_nat)
    WHERE a0004.iter21_nat = a0005.iter2_nat)

SELECT 1 AS iter32_nat, a0006.iter2_nat
   FROM t0002 AS a0006
  WHERE a0006.pos26_nat = 1
    AND a0006.item22_int = 3;


WITH
-- binding due to rank operator
t0000 (item1_int, iter2_nat, item3_int, item4_int, iter5_nat,
  item6_int, item7_int, iter8_nat, item9_int, item10_int, iter11_nat,
  iter12_nat) AS
  (SELECT a0000.item1_int, a0000.iter2_nat, a0000.item3_int,
          (a0000.item1_int + a0000.item3_int) AS item4_int, 1 AS iter5_nat,
          2 AS item6_int, (a0000.item1_int + 2) AS item7_int, 2 AS iter8_nat,
          3 AS item9_int, (a0000.item1_int + 3) AS item10_int, 3 AS iter11_nat,
          DENSE_RANK () OVER (ORDER BY a0000.iter2_nat ASC) AS iter12_nat
     FROM (VALUES (1, 1, 1),
                 (2, 2, 1),
                 (3, 3, 1)) AS a0000(item1_int,
          iter2_nat,
          item3_int)),

-- binding due to set operation
t0001 (iter13_nat, item14_int, iter15_nat) AS
  ((SELECT a0003.iter12_nat AS iter13_nat, a0003.item7_int AS item14_int,
           a0003.iter8_nat AS iter15_nat
      FROM t0000 AS a0003)
   UNION ALL
   (SELECT a0004.iter12_nat AS iter13_nat, a0004.item10_int AS item14_int,
           a0004.iter11_nat AS iter15_nat
      FROM t0000 AS a0004)),

-- binding due to set operation
t0002 (iter16_nat, item17_int, iter18_nat) AS
  ((SELECT a0002.iter12_nat AS iter16_nat, a0002.item4_int AS item17_int,
           a0002.iter5_nat AS iter18_nat
      FROM t0000 AS a0002)
   UNION ALL
   (SELECT a0005.iter13_nat AS iter16_nat, a0005.item14_int AS item17_int,
           a0005.iter15_nat AS iter18_nat
      FROM t0001 AS a0005)),

-- binding due to rownum operator
t0003 (iter2_nat, item4_int, iter5_nat, item7_int, iter8_nat,
  item10_int, iter11_nat, iter12_nat, item17_int, iter18_nat, pos21_nat) AS
  (SELECT a0001.iter2_nat, a0001.item4_int, a0001.iter5_nat, a0001.item7_int,
          a0001.iter8_nat, a0001.item10_int, a0001.iter11_nat, a0001.iter12_nat,
          a0006.item17_int, a0006.iter18_nat,
          ROW_NUMBER () OVER
          (PARTITION BY a0001.iter2_nat ORDER BY a0006.iter18_nat ASC) AS
          pos21_nat
     FROM t0000 AS a0001,
          t0002 AS a0006
    WHERE a0001.iter12_nat = a0006.iter16_nat)

SELECT a0008.item17_int AS item24_int, a0007.iter12_nat
   FROM t0003 AS a0007,
        t0002 AS a0008
  WHERE a0007.iter12_nat = a0008.iter16_nat
    AND a0007.pos21_nat = 1
    AND a0007.item17_int = 3
  ORDER BY a0007.iter12_nat ASC, a0008.iter18_nat ASC;
