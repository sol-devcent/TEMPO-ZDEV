*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPBF............................................*
DATA:  BEGIN OF STATUS_ZPBF                          .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPBF                          .
CONTROLS: TCTRL_ZPBF
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZPBF                          .
TABLES: ZPBF                           .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
