*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNRCNCUST......................................*
DATA:  BEGIN OF STATUS_ZFNRCNCUST                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRCNCUST                    .
CONTROLS: TCTRL_ZFNRCNCUST
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFNRCNCUST                    .
TABLES: ZFNRCNCUST                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
