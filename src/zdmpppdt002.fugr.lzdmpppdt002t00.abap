*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDMPPPDT002.....................................*
DATA:  BEGIN OF STATUS_ZDMPPPDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDMPPPDT002                   .
CONTROLS: TCTRL_ZDMPPPDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZDMPPPDT002                   .
TABLES: ZDMPPPDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
