*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPMMDT002.....................................*
DATA:  BEGIN OF STATUS_ZTSPMMDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPMMDT002                   .
CONTROLS: TCTRL_ZTSPMMDT002
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZTSPMMDT002                   .
TABLES: ZTSPMMDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
