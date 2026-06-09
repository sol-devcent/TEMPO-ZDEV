*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSRANGE_SO......................................*
DATA:  BEGIN OF STATUS_ZSRANGE_SO                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSRANGE_SO                    .
CONTROLS: TCTRL_ZSRANGE_SO
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZSRANGE_SO                    .
TABLES: ZSRANGE_SO                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
