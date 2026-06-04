*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHSMMMDT005.....................................*
DATA:  BEGIN OF STATUS_ZHSMMMDT005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHSMMMDT005                   .
CONTROLS: TCTRL_ZHSMMMDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZHSMMMDT005                   .
TABLES: ZHSMMMDT005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
