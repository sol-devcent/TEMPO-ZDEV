*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZALOKTR02.......................................*
DATA:  BEGIN OF STATUS_ZALOKTR02                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZALOKTR02                     .
CONTROLS: TCTRL_ZALOKTR02
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZALOKTR02                     .
TABLES: ZALOKTR02                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
