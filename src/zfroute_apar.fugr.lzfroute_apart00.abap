*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFROUTE_APAR....................................*
DATA:  BEGIN OF STATUS_ZFROUTE_APAR                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFROUTE_APAR                  .
CONTROLS: TCTRL_ZFROUTE_APAR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFROUTE_APAR                  .
TABLES: ZFROUTE_APAR                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
