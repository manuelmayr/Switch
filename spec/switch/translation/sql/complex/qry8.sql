
WITH
-- binding due to aggregate
t0000 (iter11_nat, item17_bool) AS
  (SELECT a0000.iter9_nat AS iter11_nat,
          MIN (CASE WHEN NOT (a0001.item3_int = a0001.item5_int) THEN 1 ELSE 0
          END) AS item17_bool
     FROM (VALUES (1, 1),
                 (2, 2),
                 (3, 3)) AS a0000(iter8_nat,
          iter9_nat),
          (VALUES (1, 1, 3),
                 (2, 1, 3),
                 (3, 1, 3),
                 (3, 2, 3),
                 (3, 2, 3),
                 (4, 3, 3)) AS a0001(item3_int,
          iter4_nat,
          item5_int)
    WHERE a0000.iter8_nat = a0001.iter4_nat
    GROUP BY a0000.iter9_nat)

SELECT 1 AS iter21_nat, a0003.iter2_nat
   FROM t0000 AS a0002,
        (VALUES (1, 1),
               (2, 2),
               (3, 3)) AS a0003(iter1_nat,
        iter2_nat)
  WHERE a0002.iter11_nat = a0003.iter1_nat
    AND NOT (a0002.item17_bool = 1);


WITH
-- binding due to rank operator
t0000 (item8_int, iter9_nat, iter10_nat, pos11_nat) AS
  (SELECT a0001.item8_int, a0001.iter9_nat, a0001.iter10_nat,
          DENSE_RANK () OVER (ORDER BY a0001.iter9_nat ASC) AS pos11_nat
     FROM (VALUES (1, 1, 1),
                 (2, 2, 1),
                 (3, 3, 1)) AS a0001(item8_int,
          iter9_nat,
          iter10_nat)),

-- binding due to rank operator
t0001 (item4_int, iter5_nat, iter6_nat, pos7_nat) AS
  (SELECT a0003.item4_int, a0003.iter5_nat, a0003.iter6_nat,
          DENSE_RANK () OVER (ORDER BY a0003.iter5_nat ASC) AS pos7_nat
     FROM (VALUES (3, 1, 2),
                 (3, 2, 2)) AS a0003(item4_int,
          iter5_nat,
          iter6_nat)),

-- binding due to set operation
t0002 (item12_int, iter13_nat, pos14_nat) AS
  ((SELECT a0002.item8_int AS item12_int, a0002.iter10_nat AS iter13_nat,
           a0002.pos11_nat AS pos14_nat
      FROM t0000 AS a0002)
   UNION ALL
   (SELECT a0004.item4_int AS item12_int, a0004.iter6_nat AS iter13_nat,
           a0004.pos7_nat AS pos14_nat
      FROM t0001 AS a0004)),

-- binding due to set operation
t0003 (pos15_nat, pos15_int, item16_int, iter17_nat) AS
  ((SELECT a0005.pos14_nat AS pos15_nat, CAST(NULL AS INTEGER) AS pos15_int,
           a0005.item12_int AS item16_int, a0005.iter13_nat AS iter17_nat
      FROM t0002 AS a0005)
   UNION ALL
   (SELECT CAST(NULL AS INTEGER) AS pos15_nat, a0006.pos1_int AS pos15_int,
           a0006.item2_int AS item16_int, a0006.iter3_nat AS iter17_nat
      FROM (VALUES (1, 4, 3)) AS a0006(pos1_int,
           item2_int,
           iter3_nat))),

-- binding due to aggregate
t0004 (iter27_nat, item34_bool) AS
  (SELECT a0000.iter25_nat AS iter27_nat,
          MIN (CASE WHEN NOT (a0007.item16_int = 3) THEN 1 ELSE 0 END) AS
          item34_bool
     FROM (VALUES (1, 1),
                 (2, 2),
                 (3, 3)) AS a0000(iter24_nat,
          iter25_nat),
          t0003 AS a0007
    WHERE a0000.iter24_nat = a0007.iter17_nat
    GROUP BY a0000.iter25_nat)

SELECT a0010.item16_int AS item44_int, a0009.iter18_nat AS iter40_nat
   FROM t0004 AS a0008,
        (VALUES (1, 1, 1),
               (2, 2, 2),
               (3, 3, 3)) AS a0009(iter18_nat,
        iter19_nat,
        iter20_nat),
        t0003 AS a0010
  WHERE a0008.iter27_nat = a0009.iter19_nat
    AND NOT (a0008.item34_bool = 1)
    AND a0009.iter20_nat = a0010.iter17_nat
  ORDER BY a0009.iter18_nat ASC, a0010.pos15_int ASC, a0010.pos15_nat ASC;
