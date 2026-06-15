*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTNPQMDT002.....................................*
DATA:  BEGIN OF STATUS_ZTNPQMDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTNPQMDT002                   .
CONTROLS: TCTRL_ZTNPQMDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTNPQMDT002                   .
TABLES: ZTNPQMDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
