
SELECT a0000.iter3_nat, a0000.item1_int
   FROM (VALUES (1, 1, 1),
               (2, 2, 1),
               (3, 3, 1)) AS a0000(item1_int,
        pos2_nat,
        iter3_nat)
  ORDER BY a0000.iter3_nat ASC, a0000.pos2_nat ASC;
