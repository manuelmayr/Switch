
SELECT a0000.item3_bool, a0000.iter1_nat
   FROM (VALUES (1, 1, 1)) AS a0000(iter1_nat,
        pos2_nat,
        item3_bool)
  ORDER BY a0000.iter1_nat ASC, a0000.pos2_nat ASC;
