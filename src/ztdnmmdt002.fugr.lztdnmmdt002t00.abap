*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTDNMMDT002.....................................*
DATA:  BEGIN OF STATUS_ZTDNMMDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDNMMDT002                   .
CONTROLS: TCTRL_ZTDNMMDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTDNMMDT002                   .
TABLES: ZTDNMMDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
