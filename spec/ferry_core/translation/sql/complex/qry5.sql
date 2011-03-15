
WITH
-- binding due to rank operator
t0000 (item35_int, iter36_nat, iter37_nat, pos38_nat) AS
  (SELECT a0000.item35_int, a0000.iter36_nat, a0000.iter37_nat,
          DENSE_RANK () OVER (ORDER BY a0000.iter36_nat ASC) AS pos38_nat
     FROM (VALUES (12, 1, 2),
                 (42, 2, 2)) AS a0000(item35_int,
          iter36_nat,
          iter37_nat)),

-- binding due to rank operator
t0001 (item23_str, iter24_nat, iter25_nat, pos26_nat) AS
  (SELECT a0002.item23_str, a0002.iter24_nat, a0002.iter25_nat,
          DENSE_RANK () OVER (ORDER BY a0002.iter24_nat ASC) AS pos26_nat
     FROM (VALUES ('snafu', 1, 2),
                 ('foobar', 2, 2)) AS a0002(item23_str,
          iter24_nat,
          iter25_nat)),

-- binding due to rownum operator
t0002 (item1_int, item2_str, item3_dbl, pos4_nat) AS
  (SELECT a0004.id AS item1_int, a0004.name AS item2_str,
          a0004.price AS item3_dbl,
          ROW_NUMBER () OVER (ORDER BY a0004.name ASC) AS pos4_nat
     FROM article AS a0004),

-- binding due to rownum operator
t0003 (item1_int, item2_str, item3_dbl, pos4_nat, item5_int,
  item6_nat, pos7_bool, pos8_bool, pos9_bool, pos10_nat) AS
  (SELECT a0005.item1_int, a0005.item2_str, a0005.item3_dbl, a0005.pos4_nat,
          10 AS item5_int, 10 AS item6_nat,
          CASE WHEN a0005.pos4_nat < 10 THEN 1 ELSE 0 END AS pos7_bool,
          CASE WHEN a0005.pos4_nat = 10 THEN 1 ELSE 0 END AS pos8_bool,
          CASE WHEN ((a0005.pos4_nat < 10) OR (a0005.pos4_nat = 10)) THEN 1 ELSE
          0 END AS pos9_bool,
          ROW_NUMBER () OVER (ORDER BY a0005.pos4_nat ASC) AS pos10_nat
     FROM t0002 AS a0005
    WHERE ((a0005.pos4_nat < 10) OR (a0005.pos4_nat = 10))),

-- binding due to rownum operator
t0004 (item1_int, item2_str, item3_dbl, pos4_nat, item5_int,
  item6_nat, pos7_bool, pos8_bool, pos9_bool, pos10_nat, item11_int,
  item12_nat, pos13_bool, pos14_bool, pos15_bool, pos16_nat) AS
  (SELECT a0006.item1_int, a0006.item2_str, a0006.item3_dbl, a0006.pos4_nat,
          a0006.item5_int, a0006.item6_nat, a0006.pos7_bool, a0006.pos8_bool,
          a0006.pos9_bool, a0006.pos10_nat, 9 AS item11_int, 9 AS item12_nat,
          CASE WHEN a0006.pos10_nat < 9 THEN 1 ELSE 0 END AS pos13_bool,
          CASE WHEN a0006.pos10_nat = 9 THEN 1 ELSE 0 END AS pos14_bool,
          CASE WHEN ((a0006.pos10_nat < 9) OR (a0006.pos10_nat = 9)) THEN 1 ELSE
          0 END AS pos15_bool,
          ROW_NUMBER () OVER (ORDER BY a0006.pos10_nat ASC) AS pos16_nat
     FROM t0003 AS a0006
    WHERE ((a0006.pos10_nat < 9) OR (a0006.pos10_nat = 9))),

-- binding due to set operation
t0005 (item27_str, iter28_nat, pos29_nat) AS
  ((SELECT a0003.item23_str AS item27_str, a0003.iter25_nat AS iter28_nat,
           a0003.pos26_nat AS pos29_nat
      FROM t0001 AS a0003)
   UNION ALL
   (SELECT a0007.item2_str AS item27_str, 1 AS iter28_nat,
           a0007.pos16_nat AS pos29_nat
      FROM t0004 AS a0007
     WHERE ((a0007.pos16_nat < 8) OR (a0007.pos16_nat = 8)))),

-- binding due to rownum operator
t0006 (item27_str, iter28_nat, pos29_nat, pos30_nat) AS
  (SELECT a0008.item27_str, a0008.iter28_nat, a0008.pos29_nat,
          ROW_NUMBER () OVER
          (ORDER BY a0008.iter28_nat ASC, a0008.pos29_nat ASC) AS pos30_nat
     FROM t0005 AS a0008),

-- binding due to set operation
t0007 (item39_int, item39_str, iter40_nat, pos41_nat) AS
  ((SELECT a0001.item35_int AS item39_int,
           CAST(NULL AS VARCHAR(100)) AS item39_str,
           a0001.iter37_nat AS iter40_nat, a0001.pos38_nat AS pos41_nat
      FROM t0000 AS a0001)
   UNION ALL
   (SELECT CAST(NULL AS INTEGER) AS item39_int, a0009.item27_str AS item39_str,
           1 AS iter40_nat, a0009.pos30_nat AS pos41_nat
      FROM t0006 AS a0009
     WHERE 5 < a0009.pos30_nat)),

-- binding due to rownum operator
t0008 (item39_int, item39_str, iter40_nat, pos41_nat, pos42_nat) AS
  (SELECT a0010.item39_int, a0010.item39_str, a0010.iter40_nat, a0010.pos41_nat,
          ROW_NUMBER () OVER
          (ORDER BY a0010.iter40_nat ASC, a0010.pos41_nat ASC) AS pos42_nat
     FROM t0007 AS a0010)

SELECT 1 AS iter46_nat, a0011.item39_str, a0011.item39_int
   FROM t0008 AS a0011
  WHERE 5 < a0011.pos42_nat
  ORDER BY a0011.pos42_nat ASC;
