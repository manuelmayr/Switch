SELECT a0000.item5_str, a0000.item4_str, a0000.item3_int, a0000.iter2_nat
   FROM (VALUES (1, 1, 10, 'a', 'b')) AS a0000(pos1_nat,
        iter2_nat,
        item3_int,
        item4_str,
        item5_str)
  ORDER BY a0000.iter2_nat ASC, a0000.pos1_nat ASC;

SELECT a0000.iter3_nat, a0000.item1_int
   FROM (VALUES (1, 1, 1),
               (2, 2, 1)) AS a0000(item1_int,
        pos2_nat,
        iter3_nat)
  ORDER BY a0000.iter3_nat ASC, a0000.pos2_nat ASC;
