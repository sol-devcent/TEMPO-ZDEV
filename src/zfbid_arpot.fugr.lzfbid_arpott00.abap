*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBID_ARPOT.....................................*
DATA:  BEGIN OF STATUS_ZFBID_ARPOT                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBID_ARPOT                   .
CONTROLS: TCTRL_ZFBID_ARPOT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFBID_ARPOT                   .
TABLES: ZFBID_ARPOT                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
