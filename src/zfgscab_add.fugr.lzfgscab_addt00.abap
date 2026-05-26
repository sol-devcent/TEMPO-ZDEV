*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_ADD.....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_ADD                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_ADD                   .
CONTROLS: TCTRL_ZFGSCAB_ADD
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_ADD                   .
TABLES: ZFGSCAB_ADD                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
