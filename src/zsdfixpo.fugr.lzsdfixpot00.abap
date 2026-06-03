*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSDFIXPO........................................*
DATA:  BEGIN OF STATUS_ZSDFIXPO                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSDFIXPO                      .
CONTROLS: TCTRL_ZSDFIXPO
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSDFIXPO                      .
TABLES: ZSDFIXPO                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
