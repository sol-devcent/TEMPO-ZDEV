*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZACCDTUOM.......................................*
DATA:  BEGIN OF STATUS_ZACCDTUOM                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZACCDTUOM                     .
CONTROLS: TCTRL_ZACCDTUOM
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZACCDTUOM                     .
TABLES: ZACCDTUOM                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
