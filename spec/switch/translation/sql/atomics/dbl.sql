SELECT a0000.item3_dbl, a0000.iter1_nat
  FROM (VALUES (1, 1, 42.42)) AS a0000(iter1_nat,
        pos2_nat,
        item3_dbl)
ORDER BY a0000.iter1_nat ASC, a0000.pos2_nat ASC;
