SELECT a0000.item3_int, a0000.iter1_nat
  FROM (VALUES (1, 1, 42)) AS a0000(iter1_nat,
        pos2_nat,
        item3_int)
ORDER BY a0000.iter1_nat ASC, a0000.pos2_nat ASC;
 
