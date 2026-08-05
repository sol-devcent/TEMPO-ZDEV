*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPFIDT03......................................*
DATA:  BEGIN OF STATUS_ZTSPFIDT03                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPFIDT03                    .
CONTROLS: TCTRL_ZTSPFIDT03
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPFIDT03                    .
TABLES: ZTSPFIDT03                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
