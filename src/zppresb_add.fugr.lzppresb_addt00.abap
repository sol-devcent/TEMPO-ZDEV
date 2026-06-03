*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPPRESB_ADD.....................................*
DATA:  BEGIN OF STATUS_ZPPRESB_ADD                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPPRESB_ADD                   .
CONTROLS: TCTRL_ZPPRESB_ADD
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZPPRESB_ADD                   .
TABLES: ZPPRESB_ADD                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
