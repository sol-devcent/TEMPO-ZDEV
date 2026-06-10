*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTKMSDDT002.....................................*
DATA:  BEGIN OF STATUS_ZTKMSDDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTKMSDDT002                   .
CONTROLS: TCTRL_ZTKMSDDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTKMSDDT002                   .
TABLES: ZTKMSDDT002                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
