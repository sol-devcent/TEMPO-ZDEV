*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFACCT..........................................*
DATA:  BEGIN OF STATUS_ZFACCT                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFACCT                        .
CONTROLS: TCTRL_ZFACCT
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFACCT                        .
TABLES: ZFACCT                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
