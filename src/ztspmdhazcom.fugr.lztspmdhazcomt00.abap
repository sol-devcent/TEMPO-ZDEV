*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPMDHAZCOM....................................*
DATA:  BEGIN OF STATUS_ZTSPMDHAZCOM                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPMDHAZCOM                  .
CONTROLS: TCTRL_ZTSPMDHAZCOM
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPMDHAZCOM                  .
TABLES: ZTSPMDHAZCOM                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
