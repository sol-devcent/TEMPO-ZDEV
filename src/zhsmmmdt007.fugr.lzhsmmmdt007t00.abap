*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHSMMMDT007.....................................*
DATA:  BEGIN OF STATUS_ZHSMMMDT007                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHSMMMDT007                   .
CONTROLS: TCTRL_ZHSMMMDT007
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZHSMMMDT007                   .
TABLES: ZHSMMMDT007                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
