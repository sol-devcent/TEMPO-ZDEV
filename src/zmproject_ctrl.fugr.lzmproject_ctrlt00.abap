*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMPROJECT_CTRL..................................*
DATA:  BEGIN OF STATUS_ZMPROJECT_CTRL                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMPROJECT_CTRL                .
CONTROLS: TCTRL_ZMPROJECT_CTRL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMPROJECT_CTRL                .
TABLES: ZMPROJECT_CTRL                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
