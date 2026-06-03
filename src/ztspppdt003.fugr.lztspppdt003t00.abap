*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT003.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT003                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT003                   .
CONTROLS: TCTRL_ZTSPPPDT003
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT003                   .
TABLES: ZTSPPPDT003                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
