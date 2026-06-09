*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTDNFIDT005.....................................*
DATA:  BEGIN OF STATUS_ZTDNFIDT005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDNFIDT005                   .
CONTROLS: TCTRL_ZTDNFIDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTDNFIDT005                   .
TABLES: ZTDNFIDT005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
