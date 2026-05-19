*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB.........................................*
DATA:  BEGIN OF STATUS_ZFGSCAB                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB                       .
CONTROLS: TCTRL_ZFGSCAB
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB                       .
TABLES: ZFGSCAB                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
