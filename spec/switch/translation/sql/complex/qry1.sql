
WITH
-- binding due to rownum operator
t0000 (item1_int, item2_str, item3_dbl, pos4_nat) AS
  (SELECT a0000.id AS item1_int, a0000.name AS item2_str,
          a0000.price AS item3_dbl,
          ROW_NUMBER () OVER (ORDER BY a0000.name ASC) AS pos4_nat
     FROM article AS a0000)

SELECT 1 AS iter10_nat, a0001.item2_str
   FROM t0000 AS a0001
  WHERE ((a0001.pos4_nat < 5) OR (a0001.pos4_nat = 5))
  ORDER BY a0001.pos4_nat ASC;
