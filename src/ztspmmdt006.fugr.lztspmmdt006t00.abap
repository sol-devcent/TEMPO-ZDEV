*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPMMDT006.....................................*
DATA:  BEGIN OF STATUS_ZTSPMMDT006                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPMMDT006                   .
CONTROLS: TCTRL_ZTSPMMDT006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPMMDT006                   .
TABLES: ZTSPMMDT006                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
