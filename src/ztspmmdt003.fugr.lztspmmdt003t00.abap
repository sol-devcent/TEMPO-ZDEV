*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPMMDT003.....................................*
DATA:  BEGIN OF STATUS_ZTSPMMDT003                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPMMDT003                   .
CONTROLS: TCTRL_ZTSPMMDT003
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZTSPMMDT003                   .
TABLES: ZTSPMMDT003                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
