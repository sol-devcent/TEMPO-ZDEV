*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMSHPHISTR......................................*
DATA:  BEGIN OF STATUS_ZMSHPHISTR                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMSHPHISTR                    .
CONTROLS: TCTRL_ZMSHPHISTR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMSHPHISTR                    .
TABLES: ZMSHPHISTR                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
