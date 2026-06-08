*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZALOKTR01.......................................*
DATA:  BEGIN OF STATUS_ZALOKTR01                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZALOKTR01                     .
CONTROLS: TCTRL_ZALOKTR01
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZALOKTR01                     .
TABLES: ZALOKTR01                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
