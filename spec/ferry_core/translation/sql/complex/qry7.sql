
WITH
-- binding due to aggregate
t0000 (iter8_nat, item13_bool) AS
  (SELECT a0001.iter2_nat AS iter8_nat,
          MIN (CASE WHEN a0002.item3_int = a0002.item5_int THEN 1 ELSE 0 END) AS
          item13_bool
     FROM (VALUES (1, 1),
                 (2, 2),
                 (3, 3)) AS a0001(iter1_nat,
          iter2_nat),
          (VALUES (1, 1, 3),
                 (2, 1, 3),
                 (3, 1, 3),
                 (3, 2, 3),
                 (3, 2, 3),
                 (4, 3, 3)) AS a0002(item3_int,
          iter4_nat,
          item5_int)
    WHERE a0001.iter1_nat = a0002.iter4_nat
    GROUP BY a0001.iter2_nat),

-- binding due to set operation
t0001 (iter15_nat) AS
  ((SELECT a0000.iter14_nat AS iter15_nat
      FROM (VALUES (1),
                  (2),
                  (3)) AS a0000(iter14_nat))
   EXCEPT ALL
   (SELECT a0003.iter8_nat AS iter15_nat
      FROM t0000 AS a0003)),

-- binding due to set operation
t0002 (iter17_nat, item18_bool) AS
  ((SELECT a0004.iter15_nat AS iter17_nat, 1 AS item18_bool
      FROM t0001 AS a0004)
   UNION ALL
   (SELECT a0005.iter8_nat AS iter17_nat, a0005.item13_bool AS item18_bool
      FROM t0000 AS a0005))

SELECT 1 AS iter21_nat, a0007.iter2_nat
   FROM t0002 AS a0006,
        (VALUES (1, 1),
               (2, 2),
               (3, 3)) AS a0007(iter1_nat,
        iter2_nat)
  WHERE a0006.iter17_nat = a0007.iter1_nat
    AND a0006.item18_bool = 1;


WITH
-- binding due to rank operator
t0000 (item8_int, iter9_nat, iter10_nat, pos11_nat) AS
  (SELECT a0002.item8_int, a0002.iter9_nat, a0002.iter10_nat,
          DENSE_RANK () OVER (ORDER BY a0002.iter9_nat ASC) AS pos11_nat
     FROM (VALUES (1, 1, 1),
                 (2, 2, 1),
                 (3, 3, 1)) AS a0002(item8_int,
          iter9_nat,
          iter10_nat)),

-- binding due to rank operator
t0001 (item4_int, iter5_nat, iter6_nat, pos7_nat) AS
  (SELECT a0004.item4_int, a0004.iter5_nat, a0004.iter6_nat,
          DENSE_RANK () OVER (ORDER BY a0004.iter5_nat ASC) AS pos7_nat
     FROM (VALUES (3, 1, 2),
                 (3, 2, 2)) AS a0004(item4_int,
          iter5_nat,
          iter6_nat)),

-- binding due to set operation
t0002 (item12_int, iter13_nat, pos14_nat) AS
  ((SELECT a0003.item8_int AS item12_int, a0003.iter10_nat AS iter13_nat,
           a0003.pos11_nat AS pos14_nat
      FROM t0000 AS a0003)
   UNION ALL
   (SELECT a0005.item4_int AS item12_int, a0005.iter6_nat AS iter13_nat,
           a0005.pos7_nat AS pos14_nat
      FROM t0001 AS a0005)),

-- binding due to set operation
t0003 (pos15_nat, pos15_int, item16_int, iter17_nat) AS
  ((SELECT a0006.pos14_nat AS pos15_nat, CAST(NULL AS INTEGER) AS pos15_int,
           a0006.item12_int AS item16_int, a0006.iter13_nat AS iter17_nat
      FROM t0002 AS a0006)
   UNION ALL
   (SELECT CAST(NULL AS INTEGER) AS pos15_nat, a0007.pos1_int AS pos15_int,
           a0007.item2_int AS item16_int, a0007.iter3_nat AS iter17_nat
      FROM (VALUES (1, 4, 3)) AS a0007(pos1_int,
           item2_int,
           iter3_nat))),

-- binding due to aggregate
t0004 (iter26_nat, item32_bool) AS
  (SELECT a0001.iter24_nat AS iter26_nat,
          MIN (CASE WHEN a0008.item16_int = 3 THEN 1 ELSE 0 END) AS item32_bool
     FROM (VALUES (1, 1),
                 (2, 2),
                 (3, 3)) AS a0001(iter23_nat,
          iter24_nat),
          t0003 AS a0008
    WHERE a0001.iter23_nat = a0008.iter17_nat
    GROUP BY a0001.iter24_nat),

-- binding due to set operation
t0005 (iter34_nat) AS
  ((SELECT a0000.iter33_nat AS iter34_nat
      FROM (VALUES (1),
                  (2),
                  (3)) AS a0000(iter33_nat))
   EXCEPT ALL
   (SELECT a0009.iter26_nat AS iter34_nat
      FROM t0004 AS a0009)),

-- binding due to set operation
t0006 (iter36_nat, item37_bool) AS
  ((SELECT a0010.iter34_nat AS iter36_nat, 1 AS item37_bool
      FROM t0005 AS a0010)
   UNION ALL
   (SELECT a0011.iter26_nat AS iter36_nat, a0011.item32_bool AS item37_bool
      FROM t0004 AS a0011))

SELECT a0014.item16_int AS item45_int, a0013.iter18_nat AS iter42_nat
   FROM t0006 AS a0012,
        (VALUES (1, 1, 1),
               (2, 2, 2),
               (3, 3, 3)) AS a0013(iter18_nat,
        iter19_nat,
        iter20_nat),
        t0003 AS a0014
  WHERE a0012.iter36_nat = a0013.iter19_nat
    AND a0012.item37_bool = 1
    AND a0013.iter20_nat = a0014.iter17_nat
  ORDER BY a0013.iter18_nat ASC, a0014.pos15_int ASC, a0014.pos15_nat ASC;
