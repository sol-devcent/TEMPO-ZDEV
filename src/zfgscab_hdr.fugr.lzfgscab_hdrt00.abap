*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_HDR.....................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_HDR                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_HDR                   .
CONTROLS: TCTRL_ZFGSCAB_HDR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_HDR                   .
TABLES: ZFGSCAB_HDR                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
