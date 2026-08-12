FUNCTION-POOL zdmpfg001.                    "MESSAGE-ID ..

TYPES: BEGIN OF ty_yield,
         aufpl      TYPE c LENGTH 10,
         aplzl      TYPE c LENGTH 8,
         aufnr      TYPE c LENGTH 12,
         vornr      TYPE c LENGTH 4,
         yield      TYPE p LENGTH 8 DECIMALS 3,
         meins      TYPE c LENGTH 3,
         dates_opr  TYPE datum,                 "c LENGTH 8,
         times_opr  TYPE uzeit,                 "c LENGTH 8,
         dates_conf TYPE datum,                 "c LENGTH 8,
         times_conf TYPE uzeit,                 "c LENGTH 8,
         datef      TYPE datum,                 "c LENGTH 8,
         timef      TYPE uzeit,                 "c LENGTH 8,
         rooms      TYPE c LENGTH 20,
         budat      TYPE datum,                 "c LENGTH 8,
         mhour      TYPE p LENGTH 8 DECIMALS 3,
         lhour      TYPE p LENGTH 8 DECIMALS 3,
         stats      TYPE c LENGTH 4,
         operator   TYPE c LENGTH 40,
         pengawas   TYPE c LENGTH 40,
         ltxa1      TYPE c LENGTH 40,
       END OF ty_yield.

DATA: gs_yield TYPE ty_yield,
      gs_lines LIKE tline.

* INCLUDE LZDMPFG001D...                     " Local class definition
