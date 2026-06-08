*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTNTREASON.....................................*
DATA:  BEGIN OF STATUS_ZFTNTREASON                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTNTREASON                   .
CONTROLS: TCTRL_ZFTNTREASON
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFTNTREASON                   .
TABLES: ZFTNTREASON                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
