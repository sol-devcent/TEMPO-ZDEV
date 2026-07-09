*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_DTL.....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_DTL                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_DTL                   .
CONTROLS: TCTRL_ZFGSCAB_DTL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_DTL                   .
TABLES: ZFGSCAB_DTL                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
