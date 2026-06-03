*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPMMDT005.....................................*
DATA:  BEGIN OF STATUS_ZTSPMMDT005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPMMDT005                   .
CONTROLS: TCTRL_ZTSPMMDT005
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZTSPMMDT005                   .
TABLES: ZTSPMMDT005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
