*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSCAB_CL......................................*
DATA:  BEGIN OF STATUS_ZFGSCAB_CL                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSCAB_CL                    .
CONTROLS: TCTRL_ZFGSCAB_CL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSCAB_CL                    .
TABLES: ZFGSCAB_CL                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
