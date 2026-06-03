*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMMVT_CNTRL....................................*
DATA:  BEGIN OF STATUS_ZMMMVT_CNTRL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMMVT_CNTRL                  .
CONTROLS: TCTRL_ZMMMVT_CNTRL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMMVT_CNTRL                  .
TABLES: ZMMMVT_CNTRL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
