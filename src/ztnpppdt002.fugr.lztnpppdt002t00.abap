*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTNPPPDT002.....................................*
DATA:  BEGIN OF STATUS_ZTNPPPDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTNPPPDT002                   .
CONTROLS: TCTRL_ZTNPPPDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTNPPPDT002                   .
TABLES: ZTNPPPDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
