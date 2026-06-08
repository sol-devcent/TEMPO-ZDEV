*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCLNUMBER.......................................*
DATA:  BEGIN OF STATUS_ZCLNUMBER                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCLNUMBER                     .
CONTROLS: TCTRL_ZCLNUMBER
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCLNUMBER                     .
TABLES: ZCLNUMBER                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
