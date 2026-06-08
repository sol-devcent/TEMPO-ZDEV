*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFKWIOUT........................................*
DATA:  BEGIN OF STATUS_ZFKWIOUT                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFKWIOUT                      .
CONTROLS: TCTRL_ZFKWIOUT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFKWIOUT                      .
TABLES: ZFKWIOUT                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
