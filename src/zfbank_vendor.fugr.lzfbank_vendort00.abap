*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBANK_VENDOR...................................*
DATA:  BEGIN OF STATUS_ZFBANK_VENDOR                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBANK_VENDOR                 .
CONTROLS: TCTRL_ZFBANK_VENDOR
            TYPE TABLEVIEW USING SCREEN '0110'.
*.........table declarations:.................................*
TABLES: *ZFBANK_VENDOR                 .
TABLES: ZFBANK_VENDOR                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
