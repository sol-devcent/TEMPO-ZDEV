*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_NIS.....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_NIS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_NIS                   .
CONTROLS: TCTRL_ZFGSCAB_NIS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_NIS                   .
TABLES: ZFGSCAB_NIS                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
