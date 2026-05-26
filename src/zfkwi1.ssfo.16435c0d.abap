gv_terbilang  = wa_header-amount.
SHIFT gv_terbilang LEFT DELETING LEADING space.
CONCATENATE 'Rp.' gv_terbilang '(' wa_header-amountt ')'
INTO gv_terbilang
SEPARATED BY space.






















