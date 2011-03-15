SELECT a0000.item5_int, a0000.item4_int, a0000.item3_int, a0000.iter1_nat
   FROM (VALUES (1, 1, 1, 2, 3)) AS a0000(iter1_nat,
        pos2_nat,
        item3_int,
        item4_int,
        item5_int)
  ORDER BY a0000.iter1_nat ASC, a0000.pos2_nat ASC;
