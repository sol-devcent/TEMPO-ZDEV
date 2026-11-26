*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFARPOTDCN......................................*
DATA:  BEGIN OF STATUS_ZFARPOTDCN                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFARPOTDCN                    .
CONTROLS: TCTRL_ZFARPOTDCN
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFARPOTDCN                    .
TABLES: ZFARPOTDCN                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
