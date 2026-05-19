*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFAPAR_TRN......................................*
DATA:  BEGIN OF STATUS_ZFAPAR_TRN                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFAPAR_TRN                    .
CONTROLS: TCTRL_ZFAPAR_TRN
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFAPAR_TRN                    .
TABLES: ZFAPAR_TRN                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
