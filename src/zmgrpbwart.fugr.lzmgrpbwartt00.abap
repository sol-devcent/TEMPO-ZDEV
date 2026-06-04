*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 27.03.2003 at 15:59:58 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZMGRPBWART......................................*
DATA:  BEGIN OF STATUS_ZMGRPBWART                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMGRPBWART                    .
CONTROLS: TCTRL_ZMGRPBWART
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZMGRPBWART                    .
TABLES: ZMGRPBWART                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
