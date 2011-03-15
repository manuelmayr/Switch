
SELECT 1 AS iter4_nat, ROW_NUMBER () OVER () AS iter2_nat
   FROM (VALUES (1)) AS a0000(iter1_nat);


WITH
-- binding due to rownum operator
t0000 (iter3_nat, iter4_nat) AS
  (SELECT a0000.iter3_nat, ROW_NUMBER () OVER () AS iter4_nat
     FROM (VALUES (1)) AS a0000(iter3_nat))

SELECT a0002.iter2_nat AS iter8_nat, a0001.iter4_nat AS iter6_nat
   FROM t0000 AS a0001,
        (VALUES (1, 1),
               (2, 2)) AS a0002(pos1_nat,
        iter2_nat)
  ORDER BY a0001.iter4_nat ASC, a0002.pos1_nat ASC;


SELECT DENSE_RANK () OVER (ORDER BY a0000.iter3_nat ASC) AS iter10_nat,
        ROW_NUMBER () OVER (ORDER BY a0000.iter4_nat ASC, a0001.pos1_nat ASC)
        AS iter9_nat
   FROM (VALUES (1, 1),
               (2, 2)) AS a0000(iter3_nat,
        iter4_nat),
        (VALUES (1, 1),
               (2, 1),
               (3, 1),
               (1, 2),
               (2, 2),
               (3, 2)) AS a0001(pos1_nat,
        iter2_nat)
  WHERE a0000.iter3_nat = a0001.iter2_nat
  ORDER BY a0000.iter3_nat ASC, a0001.pos1_nat ASC;


WITH
-- binding due to rownum operator
t0000 (pos27_nat, iter28_nat, item29_nat, iter30_nat) AS
  (SELECT a0001.pos27_nat, a0001.iter28_nat, a0001.item29_nat,
          ROW_NUMBER () OVER
          (ORDER BY a0001.iter28_nat ASC, a0001.pos27_nat ASC) AS iter30_nat
     FROM (VALUES (1, 1, 1),
                 (2, 1, 2),
                 (3, 1, 3),
                 (1, 2, 1),
                 (2, 2, 2),
                 (3, 2, 3)) AS a0001(pos27_nat,
          iter28_nat,
          item29_nat)),

-- binding due to rownum operator
t0001 (iter41_nat, item42_nat, pos43_nat, iter44_nat, item45_nat,
  iter46_nat, iter47_nat) AS
  (SELECT a0000.iter39_nat AS iter41_nat, a0000.item40_nat AS item42_nat,
          a0002.pos27_nat AS pos43_nat, a0002.iter28_nat AS iter44_nat,
          a0002.item29_nat AS item45_nat, a0002.iter30_nat AS iter46_nat,
          ROW_NUMBER () OVER
          (ORDER BY a0000.item40_nat ASC, a0002.pos27_nat ASC) AS iter47_nat
     FROM (VALUES (1, 1),
                 (2, 2)) AS a0000(iter39_nat,
          item40_nat),
          t0000 AS a0002
    WHERE a0000.iter39_nat = a0002.iter28_nat),

-- binding due to set operation
t0002 (iter23_nat, pos24_int, item25_int, iter26_nat) AS
  ((SELECT a0005.iter6_nat AS iter23_nat, a0006.pos13_int AS pos24_int,
           a0006.item14_int AS item25_int, a0006.iter16_nat AS iter26_nat
      FROM (VALUES (1, 1),
                  (2, 2),
                  (3, 3)) AS a0005(iter5_nat,
           iter6_nat),
           (VALUES (1, 1, 1, 1),
                  (1, 2, 2, 1),
                  (1, 3, 3, 1)) AS a0006(pos13_int,
           item14_int,
           iter15_nat,
           iter16_nat)
     WHERE a0005.iter5_nat = a0006.iter15_nat)
   UNION ALL
   (SELECT a0007.iter6_nat AS iter23_nat, a0008.pos1_int AS pos24_int,
           a0008.item2_int AS item25_int, a0008.iter4_nat AS iter26_nat
      FROM (VALUES (1, 1),
                  (2, 2),
                  (3, 3)) AS a0007(iter5_nat,
           iter6_nat),
           (VALUES (1, 4, 1, 2),
                  (1, 5, 2, 2),
                  (1, 6, 3, 2)) AS a0008(pos1_int,
           item2_int,
           iter3_nat,
           iter4_nat)
     WHERE a0007.iter5_nat = a0008.iter3_nat))

SELECT a0009.item25_int AS item57_int, a0003.iter47_nat AS iter54_nat
   FROM t0001 AS a0003,
        t0000 AS a0004,
        t0002 AS a0009
  WHERE a0004.iter28_nat = a0009.iter26_nat
    AND a0004.item29_nat = a0009.iter23_nat
    AND a0003.iter46_nat = a0004.iter30_nat
  ORDER BY a0003.iter47_nat ASC, a0009.pos24_int ASC;
