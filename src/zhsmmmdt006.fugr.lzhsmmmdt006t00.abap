*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHSMMMDT006.....................................*
DATA:  BEGIN OF STATUS_ZHSMMMDT006                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHSMMMDT006                   .
CONTROLS: TCTRL_ZHSMMMDT006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZHSMMMDT006                   .
TABLES: ZHSMMMDT006                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
