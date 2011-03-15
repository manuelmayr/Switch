
SELECT a0000.iter3_nat, a0000.iter1_nat
   FROM (VALUES (1, 1, 1),
               (2, 2, 1)) AS a0000(iter1_nat,
        pos2_nat,
        iter3_nat)
  ORDER BY a0000.iter3_nat ASC, a0000.pos2_nat ASC;


WITH
-- binding due to rank operator
t0000 (item5_int, iter6_nat, iter7_nat, pos8_nat) AS
  (SELECT a0001.item5_int, a0001.iter6_nat, a0001.iter7_nat,
          DENSE_RANK () OVER (ORDER BY a0001.iter6_nat ASC) AS pos8_nat
     FROM (VALUES (1, 1, 1),
                 (2, 2, 1),
                 (3, 3, 1)) AS a0001(item5_int,
          iter6_nat,
          iter7_nat)),

-- binding due to rank operator
t0001 (item1_int, iter2_nat, iter3_nat, pos4_nat) AS
  (SELECT a0003.item1_int, a0003.iter2_nat, a0003.iter3_nat,
          DENSE_RANK () OVER (ORDER BY a0003.iter2_nat ASC) AS pos4_nat
     FROM (VALUES (4, 1, 2),
                 (5, 2, 2),
                 (6, 3, 2)) AS a0003(item1_int,
          iter2_nat,
          iter3_nat)),

-- binding due to set operation
t0002 (item9_int, iter10_nat, pos11_nat) AS
  ((SELECT a0002.item5_int AS item9_int, a0002.iter7_nat AS iter10_nat,
           a0002.pos8_nat AS pos11_nat
      FROM t0000 AS a0002)
   UNION ALL
   (SELECT a0004.item1_int AS item9_int, a0004.iter3_nat AS iter10_nat,
           a0004.pos4_nat AS pos11_nat
      FROM t0001 AS a0004))

SELECT a0005.item9_int AS item16_int, a0000.item13_nat AS item15_nat
   FROM (VALUES (1, 1),
               (2, 2)) AS a0000(iter12_nat,
        item13_nat),
        t0002 AS a0005
  WHERE a0000.iter12_nat = a0005.iter10_nat
  ORDER BY a0000.item13_nat ASC, a0005.pos11_nat ASC;
