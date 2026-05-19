*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFAPAR_BUKRS....................................*
DATA:  BEGIN OF STATUS_ZFAPAR_BUKRS                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFAPAR_BUKRS                  .
CONTROLS: TCTRL_ZFAPAR_BUKRS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFAPAR_BUKRS                  .
TABLES: ZFAPAR_BUKRS                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
