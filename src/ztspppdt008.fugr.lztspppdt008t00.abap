*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT008.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT008                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT008                   .
CONTROLS: TCTRL_ZTSPPPDT008
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT008                   .
TABLES: ZTSPPPDT008                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
