*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFDEPT..........................................*
DATA:  BEGIN OF STATUS_ZFDEPT                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFDEPT                        .
CONTROLS: TCTRL_ZFDEPT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFDEPT                        .
TABLES: ZFDEPT                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
