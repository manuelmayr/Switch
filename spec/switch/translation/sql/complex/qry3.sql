
WITH
-- binding due to rownum operator
t0000 (iter6_nat, item8_int, iter9_nat, item5_int, iter12_nat) AS
  (SELECT a0000.iter7_nat AS iter6_nat, a0000.item8_int, a0000.iter9_nat,
          a0001.item5_int,
          ROW_NUMBER () OVER (ORDER BY a0000.iter7_nat ASC, a0000.iter9_nat ASC)
          AS iter12_nat
     FROM (VALUES (1, 1, 1),
                 (2, 1, 1),
                 (3, 1, 1),
                 (4, 1, 1),
                 (5, 1, 1),
                 (6, 1, 1),
                 (1, 2, 2),
                 (2, 2, 2),
                 (3, 2, 2),
                 (4, 2, 2),
                 (5, 2, 2),
                 (6, 2, 2),
                 (1, 3, 3),
                 (2, 3, 3),
                 (3, 3, 3),
                 (4, 3, 3),
                 (5, 3, 3),
                 (6, 3, 3),
                 (1, 4, 4),
                 (2, 4, 4),
                 (3, 4, 4),
                 (4, 4, 4),
                 (5, 4, 4),
                 (6, 4, 4),
                 (1, 5, 5),
                 (2, 5, 5),
                 (3, 5, 5),
                 (4, 5, 5),
                 (5, 5, 5),
                 (6, 5, 5),
                 (1, 6, 6),
                 (2, 6, 6),
                 (3, 6, 6),
                 (4, 6, 6),
                 (5, 6, 6),
                 (6, 6, 6)) AS a0000(iter7_nat,
          item8_int,
          iter9_nat),
          (VALUES (1, 1),
                 (2, 2),
                 (3, 3),
                 (4, 4),
                 (5, 5),
                 (6, 6)) AS a0001(item5_int,
          iter6_nat)
    WHERE a0000.iter7_nat = a0001.iter6_nat),

-- binding due to set operation
t0001 (iter16_nat, item17_int, iter18_nat) AS
  ((SELECT a0002.iter12_nat AS iter16_nat, a0002.item5_int AS item17_int,
           1 AS iter18_nat
      FROM t0000 AS a0002)
   UNION ALL
   (SELECT a0003.iter12_nat AS iter16_nat, a0003.item8_int AS item17_int,
           2 AS iter18_nat
      FROM t0000 AS a0003)),

-- binding due to rownum operator
t0002 (iter6_nat, item8_int, iter9_nat, item5_int, iter12_nat,
  iter13_nat) AS
  (SELECT a0005.iter6_nat, a0005.item8_int, a0005.iter9_nat, a0005.item5_int,
          a0005.iter12_nat,
          ROW_NUMBER () OVER (ORDER BY a0005.iter6_nat ASC, a0005.iter9_nat ASC)
          AS iter13_nat
     FROM t0000 AS a0005),

-- binding due to rownum operator
t0003 (iter12_nat, item17_int, iter18_nat, iter6_nat, item8_int,
  iter9_nat, item5_int, iter13_nat, pos21_nat) AS
  (SELECT a0004.iter16_nat AS iter12_nat, a0004.item17_int, a0004.iter18_nat,
          a0006.iter6_nat, a0006.item8_int, a0006.iter9_nat, a0006.item5_int,
          a0006.iter13_nat,
          ROW_NUMBER () OVER
          (PARTITION BY a0006.iter13_nat ORDER BY a0004.iter18_nat ASC) AS
          pos21_nat
     FROM t0001 AS a0004,
          t0002 AS a0006
    WHERE a0004.iter16_nat = a0006.iter12_nat)

SELECT 1 AS iter51_nat, a0009.iter12_nat AS iter43_nat
   FROM t0003 AS a0007,
        t0003 AS a0008,
        t0002 AS a0009,
        (VALUES (1, 2)) AS a0010(item1_int,
        item2_int)
  WHERE a0007.iter13_nat = a0008.iter13_nat
    AND a0007.iter13_nat = a0009.iter13_nat
    AND (a0007.item17_int + a0008.item17_int) = 7
    AND a0007.pos21_nat = a0010.item1_int
    AND a0008.pos21_nat = a0010.item2_int;


WITH
-- binding due to rownum operator
t0000 (iter6_nat, item8_int, iter9_nat, item5_int, iter12_nat) AS
  (SELECT a0000.iter7_nat AS iter6_nat, a0000.item8_int, a0000.iter9_nat,
          a0001.item5_int,
          ROW_NUMBER () OVER (ORDER BY a0000.iter7_nat ASC, a0000.iter9_nat ASC)
          AS iter12_nat
     FROM (VALUES (1, 1, 1),
                 (2, 1, 1),
                 (3, 1, 1),
                 (4, 1, 1),
                 (5, 1, 1),
                 (6, 1, 1),
                 (1, 2, 2),
                 (2, 2, 2),
                 (3, 2, 2),
                 (4, 2, 2),
                 (5, 2, 2),
                 (6, 2, 2),
                 (1, 3, 3),
                 (2, 3, 3),
                 (3, 3, 3),
                 (4, 3, 3),
                 (5, 3, 3),
                 (6, 3, 3),
                 (1, 4, 4),
                 (2, 4, 4),
                 (3, 4, 4),
                 (4, 4, 4),
                 (5, 4, 4),
                 (6, 4, 4),
                 (1, 5, 5),
                 (2, 5, 5),
                 (3, 5, 5),
                 (4, 5, 5),
                 (5, 5, 5),
                 (6, 5, 5),
                 (1, 6, 6),
                 (2, 6, 6),
                 (3, 6, 6),
                 (4, 6, 6),
                 (5, 6, 6),
                 (6, 6, 6)) AS a0000(iter7_nat,
          item8_int,
          iter9_nat),
          (VALUES (1, 1),
                 (2, 2),
                 (3, 3),
                 (4, 4),
                 (5, 5),
                 (6, 6)) AS a0001(item5_int,
          iter6_nat)
    WHERE a0000.iter7_nat = a0001.iter6_nat),

-- binding due to rownum operator
t0001 (iter6_nat, item8_int, iter9_nat, item5_int, iter12_nat,
  iter18_nat) AS
  (SELECT a0002.iter6_nat, a0002.item8_int, a0002.iter9_nat, a0002.item5_int,
          a0002.iter12_nat,
          ROW_NUMBER () OVER (ORDER BY a0002.iter6_nat ASC, a0002.iter9_nat ASC)
          AS iter18_nat
     FROM t0000 AS a0002),

-- binding due to set operation
t0002 (iter15_nat, item16_int, iter17_nat) AS
  ((SELECT a0004.iter12_nat AS iter15_nat, a0004.item5_int AS item16_int,
           1 AS iter17_nat
      FROM t0000 AS a0004)
   UNION ALL
   (SELECT a0005.iter12_nat AS iter15_nat, a0005.item8_int AS item16_int,
           2 AS iter17_nat
      FROM t0000 AS a0005)),

-- binding due to rownum operator
t0003 (iter12_nat, item16_int, iter17_nat, iter6_nat, item8_int,
  iter9_nat, item5_int, iter18_nat, pos21_nat) AS
  (SELECT a0006.iter15_nat AS iter12_nat, a0006.item16_int, a0006.iter17_nat,
          a0007.iter6_nat, a0007.item8_int, a0007.iter9_nat, a0007.item5_int,
          a0007.iter18_nat,
          ROW_NUMBER () OVER
          (PARTITION BY a0007.iter18_nat ORDER BY a0006.iter17_nat ASC) AS
          pos21_nat
     FROM t0002 AS a0006,
          t0001 AS a0007
    WHERE a0006.iter15_nat = a0007.iter12_nat)

SELECT a0010.item16_int AS item44_int, a0003.iter12_nat AS iter38_nat
   FROM t0001 AS a0003,
        t0003 AS a0008,
        t0003 AS a0009,
        t0002 AS a0010,
        (VALUES (1, 2)) AS a0011(item1_int,
        item2_int)
  WHERE a0008.iter18_nat = a0009.iter18_nat
    AND a0003.iter18_nat = a0008.iter18_nat
    AND a0003.iter12_nat = a0010.iter15_nat
    AND (a0008.item16_int + a0009.item16_int) = 7
    AND a0008.pos21_nat = a0011.item1_int
    AND a0009.pos21_nat = a0011.item2_int
  ORDER BY a0003.iter12_nat ASC, a0010.iter17_nat ASC;
