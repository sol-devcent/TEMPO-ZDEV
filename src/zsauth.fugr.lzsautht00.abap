*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSAUTH..........................................*
DATA:  BEGIN OF STATUS_ZSAUTH                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSAUTH                        .
CONTROLS: TCTRL_ZSAUTH
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZSAUTH                        .
TABLES: ZSAUTH                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
