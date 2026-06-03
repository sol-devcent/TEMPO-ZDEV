*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSPARAMETER.....................................*
DATA:  BEGIN OF STATUS_ZSPARAMETER                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSPARAMETER                   .
CONTROLS: TCTRL_ZSPARAMETER
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSPARAMETER                   .
TABLES: ZSPARAMETER                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
